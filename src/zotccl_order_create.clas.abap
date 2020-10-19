class ZOTCCL_ORDER_CREATE definition
  public
  final
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data GREF_MESSAGE_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .

  methods CONSTRUCTOR .
  type-pools ABAP .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
  methods REFRESH .
  methods FEH_PREPARE
    importing
      !IM_INPUT type SLS_SALES_ORDER_ERPCREATE_REQ1 .
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
  methods METH_INST_PUB_EXECUTE
    importing
      !IM_INPUT type SLS_SALES_ORDER_ERPCREATE_REQ1
    exporting
      value(EX_ORDER) type VBELN .
protected section.
private section.

  class-data ATTR_S_P_ECH_ACTION type ref to ZOTCCL_ORDER_CREATE .
  data GV_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .
  data I_FEH_DATA type ZCA_TT_FEH_DATA .
  data GV_ECH_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_FEH_GUID type FEH_GUID .

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .
ENDCLASS.



CLASS ZOTCCL_ORDER_CREATE IMPLEMENTATION.


method CONSTRUCTOR.
***********************************************************************
*Method     : if_ech_action~retry                                     *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*  *
 CREATE OBJECT gref_message_container.
endmethod.


METHOD feh_execute.
***********************************************************************
*Method     : FEH_EXECUTE                                             *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi       sales Order Async-SCTASK0768763     *
*---------------------------------------------------------------------*

*Local data declarations
  DATA:lref_registration  TYPE REF TO cl_feh_registration, " Registration and Restarting of FEH
       lref_cx_system     TYPE REF TO cx_ai_system_fault,  " Application Integration: Technical Error
       lv_raise_exception TYPE xflag,                      " New Input Values
       lv_mtext           TYPE string,
       li_bapiret         TYPE bapirettab.

  FIELD-SYMBOLS :<lfs_feh_data> TYPE zca_feh_data. " FEH Line
*  CONSTANTS  :    lc_msg_fault  TYPE classname VALUE 'CX_EBPP_STANDARD_MESSAGE_FAULT'. " Reference type
  CONSTANTS  :    lc_msg_fault  TYPE classname VALUE 'CX_SAPPLCO_STANDARD_MSG_FAULT'. " Reference type

  IF lines( i_feh_data ) > 0.
    IF im_ref_registration IS BOUND.
      CLEAR lv_raise_exception.
      lref_registration = im_ref_registration.
    ELSE. " ELSE -> IF im_ref_registration IS BOUND
      lv_raise_exception = abap_true.
      lref_registration = cl_feh_registration=>s_initialize( is_single = space ).
    ENDIF. " IF im_ref_registration IS BOUND

    TRY.
*--- Process all objects individually ---------------------*
        READ TABLE i_feh_data ASSIGNING <lfs_feh_data> INDEX 1.

        IF NOT <lfs_feh_data> IS INITIAL AND sy-subrc = 0.
*----- Error in mapping -----------------------------------*
          CALL METHOD lref_registration->collect
            EXPORTING
              i_external_guid  = <lfs_feh_data>-external_guid
              i_single_bo_ref  = <lfs_feh_data>-single_bo_ref
              i_hidden_data    = <lfs_feh_data>-hidden_data
              i_error_category = <lfs_feh_data>-error_category
              i_main_message   = <lfs_feh_data>-main_message
              i_messages       = <lfs_feh_data>-all_messages
              i_main_object    = <lfs_feh_data>-main_object
              i_objects        = <lfs_feh_data>-all_objects
              i_pre_mapping    = <lfs_feh_data>-pre_mapping.
          APPEND LINES OF <lfs_feh_data>-all_messages TO li_bapiret.
        ENDIF. " IF NOT <lfs_feh_data> IS INITIAL AND sy-subrc = 0

      CATCH cx_ai_system_fault INTO lref_cx_system.
        lv_mtext = lref_cx_system->get_text( ).
        MESSAGE x026(bs_soa_common) WITH lv_mtext. " System error in the ForwardError Handling: &1
    ENDTRY.
*----- Refresh errors --------------------------------------*
    REFRESH i_feh_data.

*----- Raise Exception -------------------------------------*
    IF lv_raise_exception = abap_true.
* Please raise the same exception in the proxy method definition.
      CALL METHOD cl_proxy_fault=>raise(
        EXPORTING
          exception_class_name = lc_msg_fault
          bapireturn_tab       = li_bapiret ).
    ENDIF. " IF lv_raise_exception = abap_true

  ENDIF. " IF lines( i_feh_data ) > 0

ENDMETHOD.


method FEH_PREPARE.
***********************************************************************
*Method     : FEH_PREPARE                                             *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*
*Local data declarations.
  DATA:lwa_feh_data         TYPE zca_feh_data,   "FEH Line
       lwa_ech_main_object  TYPE ech_str_object, "Object of Business Process
       li_applmsg           TYPE applmsgtab,     "Return Table for Messages
       lr_data              TYPE REF TO data,    "class
       lwa_bapiret          TYPE bapiret2.       "Return Parameter

  FIELD-SYMBOLS : <lfs_appl_msg> TYPE applmsg. " Return Structure for Messages
  CONSTANTS     :  lc_one        TYPE ech_dte_objcat VALUE '1'. " Object Category

* The error category should depends on the actually error not below testing category
  lwa_feh_data-error_category  = gref_message_container->get_err_category( ).

  lwa_ech_main_object-objcat  = lc_one.
  lwa_ech_main_object-objtype = me->gv_ech_objtype.
  lwa_feh_data-main_object    = lwa_ech_main_object.

  GET REFERENCE OF im_input INTO lr_data.
  IF sy-subrc EQ 0.
    lwa_feh_data-single_bo_ref = lr_data.
  ENDIF. " IF sy-subrc EQ 0

  REFRESH li_applmsg.
  li_applmsg = gref_message_container->get_appl_messages( ).
  LOOP AT li_applmsg ASSIGNING <lfs_appl_msg>.
*Moving all fields isntead of using MOVE CORRESPONDING.
    lwa_bapiret-type        = <lfs_appl_msg>-type.
    lwa_bapiret-id          = <lfs_appl_msg>-id.
    lwa_bapiret-number      = <lfs_appl_msg>-number.
    lwa_bapiret-message     = <lfs_appl_msg>-number.
    lwa_bapiret-log_no      = <lfs_appl_msg>-log_no.
    lwa_bapiret-log_msg_no  = <lfs_appl_msg>-log_msg_no.
    lwa_bapiret-message_v1  = <lfs_appl_msg>-message_v1.
    lwa_bapiret-message_v2  = <lfs_appl_msg>-message_v2.
    lwa_bapiret-message_v3  = <lfs_appl_msg>-message_v3.
    lwa_bapiret-message_v4  = <lfs_appl_msg>-message_v4.
    lwa_bapiret-parameter   = <lfs_appl_msg>-parameter.
    lwa_bapiret-row         = <lfs_appl_msg>-row.
    lwa_bapiret-field       = <lfs_appl_msg>-field.
    lwa_bapiret-system      = <lfs_appl_msg>-system.

    APPEND lwa_bapiret TO lwa_feh_data-all_messages.
    CLEAR lwa_bapiret.
  ENDLOOP. " LOOP AT li_applmsg ASSIGNING <lfs_appl_msg>

* Get main message from message container
  lwa_feh_data-main_message = gref_message_container->get_main_error( ).

*  IF lwa_feh_data-main_message IS INITIAL.
  READ TABLE lwa_feh_data-all_messages INDEX 1 INTO lwa_feh_data-main_message.
  IF sy-subrc NE 0.
    CLEAR lwa_feh_data-main_message.
  ENDIF. " IF sy-subrc NE 0
*  ENDIF. " IF lwa_feh_data-main_message IS INITIAL

*--- Store information locally ----------------------------------------------*
  APPEND lwa_feh_data TO i_feh_data.
endmethod.


method HAS_ERROR.
***********************************************************************
*Method     : if_ech_action~retry                                     *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*  *
  re_result = gref_message_container->has_error( ).
endmethod.


METHOD if_ech_action~fail.
***********************************************************************
*Method     : if_ech_action~retry                                     *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*

  CONSTANTS  : lc_fail TYPE  bs_soa_siw_dte_proc_context VALUE 'FAIL'. " Processing context of service implementation

  me->initialize( im_id_processing_context = lc_fail ).

* Set the status to failed in FEH
  CALL METHOD cl_feh_registration=>s_fail
    EXPORTING
      i_data             = i_data
    IMPORTING
      e_execution_failed = e_execution_failed
      e_return_message   = e_return_message.
ENDMETHOD.


method IF_ECH_ACTION~FINISH.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : if_ech_action~Finish                                    *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*  *


  CONSTANTS : lc_finish TYPE bs_soa_siw_dte_proc_context  VALUE 'FINISH'. " Processing context of service implementation

  me->initialize( im_id_processing_context = lc_finish ).

* Set the status to finish in FEH
  CALL METHOD cl_feh_registration=>s_finish
    EXPORTING
      i_data             = i_data
    IMPORTING
      e_execution_failed = e_execution_failed
      e_return_message   = e_return_message.
endmethod.


method IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR.
endmethod.


METHOD if_ech_action~retry.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : if_ech_action~retry                                     *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi         Sales Order Async -  SCTASK0768763   *
*---------------------------------------------------------------------*  *
*&----------------------------------------------------------------------- *

**This method needs to be implemented to trigger the reprocessing of a message.
*The message will be called if Restart in Monitoring and Error Handling is
*clicked or if Repeat in Error  and  Conflict is selected

  DATA: lref_feh_registration  TYPE REF TO cl_feh_registration           VALUE IS INITIAL,  "Registration and Restarting of FEH
        lx_input               TYPE sls_sales_order_erpcreate_req1       VALUE IS INITIAL . "Z01OTC_MT_TRANSFER_PRICE_LOAD VALUE IS INITIAL.

* Begin of Change for OTC_IDD_0222 by U033876
      DATA: lv_collection_id TYPE sysuuid_x16,                     " 16 Byte UUID in 16 Bytes (Raw Format)
            lo_process_context TYPE REF TO if_feh_process_context. " Process Environment for Conflict Handler
* Based on collection id we retrive the  attachment from proxy
      DATA: lo_msgtab      TYPE REF TO  sxmsmsglst,       "  class
            lo_xms_persist TYPE REF TO  cl_xms_persist,   " Persistency Layer for the XML Message Broker
            lo_message     TYPE REF TO  if_xms_message,   " XI: Internal Message Interface
            lo_resource    TYPE REF TO   if_xms_resource, " Interface for Message Contents Resource
            lo_error       TYPE REF TO  cx_root,          " Abstract Superclass for All Global Exceptions
            lv_data        TYPE         xstring,
            lv_fname       TYPE string,
            lv_vbeln       TYPE vbeln,                    " Sales and Distribution Document Number
            lv_size        TYPE         i,                " Size of type Integers
            li_proxymsg    TYPE sxmsmsgtab,
            lwa_proxyresult TYPE sxmsadminresult,         " Result of Admin Action
            li_ecc_msgid    TYPE sxmsmguidt,              " XI: Message ID
            lwa_ecc_msgid   TYPE sxmsmguid,               " XI: Message ID
            li_filter       TYPE sxi_msg_select.          " XI/WS: Structure for Message Selection in Database (Master)
      CONSTANTS:lc_msgcnt TYPE int4 VALUE '100', " Natural Number
                lco_1      TYPE i    VALUE 1.    " 1 of type Integers
* End of Change for OTC_IDD_0222 by U033876

  CONSTANTS: lc_retry TYPE bs_soa_siw_dte_proc_context  VALUE 'RETRY'. "Processing context of service implementation

  CLEAR e_execution_failed.
  CLEAR e_return_message.

**Initialize business logic class
  me->initialize( im_id_processing_context = lc_retry ).

**Create FEH instance for RETRY
  lref_feh_registration = cl_feh_registration=>s_retry( i_error_object_id = i_error_object_id ).


**Retrieve data stored in FEH
  CALL METHOD lref_feh_registration->retrieve_data
    EXPORTING
      i_data              = i_data
    IMPORTING
      e_post_mapping_data = lx_input.


**Reprocess the data
*  me->meth_inst_pub_execute( im_input = lx_input ).
  me->meth_inst_pub_execute( EXPORTING im_input = lx_input
                             IMPORTING ex_order = lv_vbeln ).

**If still, there is error
  IF me->has_error( ) = abap_true.
    me->feh_execute( im_ref_registration = lref_feh_registration ).

* Begin of change for OTC_IDD_0222 by U033876-SCTASK0768763
* If no error then get the attachment from error object id and
* assign the same tot he order (just got created) GOS object
  ELSE. " ELSE -> IF me->has_error( ) = abap_true

      SELECT SINGLE collection_guid " XI: Message ID
                    FROM feh_mess_ref INTO lv_collection_id
                    WHERE feh_guid = i_error_object_id.
      IF sy-subrc = 0.

        lwa_ecc_msgid = lv_collection_id.
        APPEND lwa_ecc_msgid TO li_ecc_msgid.
        CLEAR: lwa_ecc_msgid, lv_collection_id.
        li_filter-msgguid_tab = li_ecc_msgid.

        CALL FUNCTION 'SXMB_SELECT_MESSAGES_NEW'
          EXPORTING
            im_filter           = li_filter
            im_number           = lc_msgcnt
*           IM_ADAPTER_OR       = '0'
*           IM_PROCESS_MODE     = '0'
          IMPORTING
            ex_msgtab           = li_proxymsg
            ex_result           = lwa_proxyresult
*           EX_FIRST_TS         =
          EXCEPTIONS
            persist_error       = 1
            missing_parameter   = 2
            negative_time_range = 3
            too_many_parameters = 4
            no_timezone         = 5
            OTHERS              = 6.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF. " IF sy-subrc <> 0

* Fetch the payload data
        CREATE OBJECT lo_xms_persist.

        LOOP AT li_proxymsg REFERENCE INTO lo_msgtab .
          TRY.
              lo_xms_persist->read_msg_all(
                EXPORTING
                  im_msgguid = lo_msgtab->msgguid
                  im_pid     = lo_msgtab->pid
                  im_version = lo_msgtab->vers
                IMPORTING
                  ex_message = lo_message ).
            CATCH cx_xms_syserr_persist INTO lo_error.
              EXIT.
          ENDTRY.

          lv_size = lo_message->numberofattachments( ).
          IF lv_size IS NOT INITIAL.
            lo_resource =
              lo_message->getattachmentatindex( index = lco_1 ).
            TRY.
                lv_data = lo_resource->getbinarydata( ).
                lv_fname = lo_resource->gettype( ).
              CATCH: cx_xms_exception INTO lo_error, "#EC NO_HANDLER
                cx_xms_system_error INTO lo_error.   "#EC NO_HANDLER
            ENDTRY.
            IF lv_data IS NOT INITIAL AND lv_vbeln IS NOT INITIAL.
              REPLACE ALL OCCURRENCES OF '/' IN  lv_fname WITH '.'.
* fm to attach the doc to the sales order
              CALL FUNCTION 'ZOTC_GOS_ATTACH_DOC_ORD'
                EXPORTING
                  im_xstring = lv_data
                  im_vbeln   = lv_vbeln
                  im_fname   = lv_fname.
            ENDIF. " IF lv_data IS NOT INITIAL
          ENDIF. " IF lv_size IS NOT INITIAL
        ENDLOOP. " LOOP AT li_proxymsg REFERENCE INTO lo_msgtab
      ENDIF. " IF sy-subrc = 0
* End of Change for OTC_IDD_0222 by U033876- SCTASK0768763
  ENDIF. " IF me->has_error( ) = abap_true

**Update the FEH
  lref_feh_registration->resolve_retry( ).
ENDMETHOD.


METHOD if_ech_action~s_create.
***********************************************************************
*Program    : IF_ECH_ACTION~S_CREATE                                  *
*Title      : GL Balance Upload - Clearwater                          *
*Developer  : Harshit Badlani                                         *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_RTR_IDD_0030                                           *
*---------------------------------------------------------------------*
*Description:Clearwater provides a reporting platform that the        *
*business uses to run various reports. One of these report is also    *
*used to download the monthly GL transactions into a Winshuttle       *
*template for SAP upload.In D2, the business wants this upload process*
*to be automated.Also,the FI transaction should ONLY be “PARKED”.     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*22-OCT-2014  HBADLAN      E2DK905528      INITIAL DEVELOPMENT
*---------------------------------------------------------------------*

  IF NOT attr_s_p_ech_action IS BOUND.
    CREATE OBJECT attr_s_p_ech_action.
  ENDIF. " IF NOT attr_s_p_ech_action IS BOUND
  r_action_class = attr_s_p_ech_action. "  class
ENDMETHOD.


method INITIALIZE.
***********************************************************************
*Method     : INITIALIZE                                              *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*

  CONSTANTS : lc_retry   TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',  " Processing context of service implementation
              lc_fail    TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',   " Processing context of service implementation
              lc_finish  TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH', " Processing context of service implementation
              lc_objtype TYPE ech_dte_objtype             VALUE 'BUS2032'.

*--Call the refresh method message container class.
  gref_message_container->refresh( ).
  me->refresh( ).
  gv_processing_context = im_id_processing_context.

*--Check the Processing COntext
  IF gv_processing_context EQ lc_retry OR
     gv_processing_context EQ lc_fail OR
     gv_processing_context EQ lc_finish.
    REFRESH: i_feh_data.
  ENDIF. " IF gv_processing_context EQ lc_retry OR
*--Assign Business Object
  gv_ech_objtype = lc_objtype.
  attr_s_p_ech_action  = me.
endmethod.


METHOD meth_inst_pub_execute.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : Z01OTC_II_SI_ORDER_CREATE_ASYN~SI_ORDER_CREATE_ASYNC_IN *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi        Sales Order Async   SCTASK0768763  *
*---------------------------------------------------------------------*
  CONSTANTS: lc_msgid    TYPE arbgb         VALUE 'ZPTP_MSG', " Application Area
              lc_msg      TYPE symsgno       VALUE '000'.     " Message Number
  DATA:
       lv_text                         TYPE string,                                 " String
       lwa_log                         TYPE sapplco_log,                            " Proxy Structure (Generated)
       li_item                         TYPE sapplco_log_item_tab,
       lwa_item                        TYPE sapplco_log_item,                       " protocol message issued by an application
       lref_oref                       TYPE REF TO   cx_sapplco_standard_msg_fault. " Abstract Superclass for All Global Exceptions
  DATA:lref_sls_salesordererpcrtrc2    TYPE REF TO   cl_sls_salesordererpcrtrc2, " Sales Order ERP Create Request Confirmation_In V2
       lref_service_impl               TYPE REF TO  zotccl_order_create,         " Asynch Sales Order Create
       li_bapi_msg                     TYPE STANDARD TABLE OF bapiret2,          " Return Parameter
       lwa_output                      TYPE sls_sales_order_erpcreate_con1,      " Sales Order ERP Create Confirmation V2
       lwa_bapi_msg                    TYPE bapiret2.                            " Return Parameter


  DATA: li_attach    TYPE prx_attach,
        l_name       TYPE string,
        l_xstring    TYPE xstring,
        lv_fname     TYPE string,
        lv_fname1    TYPE string,
        lv_fname2    TYPE string,
        l_string     TYPE string,
        l_type       TYPE string,
        l_attachment TYPE REF TO if_ai_attachment. " Proxy Runtime: Attachments
  DATA:  lo_server_context   TYPE REF TO if_ws_server_context, " Proxy Server Context
         lo_payload_protocol TYPE REF TO if_wsprotocol.        " ABAP Proxies: Available Protocols
  DATA : l_kind TYPE sychar01. " CHAR01 data element for SYST


*create object for class cl_pur_purreqerpcrtrc1
  CREATE OBJECT lref_sls_salesordererpcrtrc2.
*  CREATE OBJECT lref_service_impl.

  CALL METHOD
    lref_sls_salesordererpcrtrc2->ii_sls_salesordererpcrtrc2~execute_synchronous
    EXPORTING
      input  = im_input
    IMPORTING
      output = lwa_output.
  IF lwa_output-sales_order_erpcreate_confirm-log-maximum_log_item_severity_code = '3'.
    li_item = lwa_output-sales_order_erpcreate_confirm-log-item.
    LOOP AT li_item INTO lwa_item WHERE severity_code = '3'.
      lv_text = lwa_item-note.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = lc_msgid.
      lwa_bapi_msg-number     = lc_msg.
      lwa_bapi_msg-message_v1 = lv_text.
      me->gref_message_container->add_bapi_message( lwa_bapi_msg ).
    ENDLOOP. " LOOP AT li_item INTO lwa_item WHERE severity_code = '3'
  ENDIF. " IF lwa_output-sales_order_erpcreate_confirm-log-maximum_log_item_severity_code = '3'

* IF ERROR HAPPENS, FILL THE ECH STRUCTURE
  IF me->has_error( ) = abap_true.
    me->gref_message_container->set_err_category( zcacl_message_container=>c_post_err_category ).
    me->feh_prepare( im_input ).

  ELSE. " ELSE -> IF me->has_error( ) = abap_true
* If no Error, export the created sales order as ex_order
    ex_order = lwa_output-sales_order_erpcreate_confirm-sales_order-sales_order-id-content.
    IF ex_order IS NOT INITIAL.
* Execute below code only when we have a sales order in iv_vbeln and attachment
      TRY.
          lo_server_context   = cl_proxy_access=>get_server_context( ).
          lo_payload_protocol = lo_server_context->get_protocol( if_wsprotocol=>payload ).
          DATA : lo_attachment_protocol TYPE REF TO      if_wsprotocol_attachments, " Only XI: Attachments
                lo_protocol_mess_id  TYPE REF TO cl_wsprotocol_message_id.          " Implementation IF_PROXY_MESSAGE_ID

          lo_attachment_protocol ?=
               lo_server_context->get_protocol( if_wsprotocol=>attachments ).

          CALL METHOD lo_attachment_protocol->get_attachments
            RECEIVING
              attachments = li_attach.
          .
        CATCH cx_ai_system_fault.
      ENDTRY.

      LOOP AT li_attach INTO l_attachment.
        CALL METHOD l_attachment->get_kind
          RECEIVING
            p_kind = l_kind.
        IF l_kind NE space.
          CALL METHOD l_attachment->get_binary_data
            RECEIVING
              p_data = l_xstring.
          CALL METHOD l_attachment->get_content_type
            RECEIVING
              p_type = lv_fname.
*          application/pdf;name="SAP note_158807.pdf"
          SPLIT lv_fname AT '=' INTO lv_fname1 lv_fname2.
          REPLACE ALL OCCURRENCES OF '"' IN  lv_fname2 WITH space.
          CONDENSE lv_fname2 NO-GAPS.
          IF lv_fname2 IS INITIAL.
            REPLACE ALL OCCURRENCES OF '/' IN  lv_fname WITH '.'.
            lv_fname2 =      lv_fname.
          ENDIF. " IF lv_fname2 IS INITIAL
        ENDIF. " IF l_kind NE space
        IF  l_xstring IS NOT INITIAL AND ex_order IS NOT INITIAL.
          CALL FUNCTION 'ZOTC_GOS_ATTACH_DOC_ORD'
            EXPORTING
              im_xstring = l_xstring
              im_vbeln   = ex_order
              im_fname   = lv_fname2.
        ENDIF. " IF l_xstring IS NOT INITIAL AND ex_order IS NOT INITIAL
      ENDLOOP. " LOOP AT li_attach INTO l_attachment
    ENDIF. " IF ex_order IS NOT INITIAL

  ENDIF. " IF me->has_error( ) = abap_true
ENDMETHOD.


method REFRESH.
***********************************************************************
*Method     : if_ech_action~retry                                     *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi                Sales Order Async          *
*---------------------------------------------------------------------*  *
  REFRESH i_feh_data.
  CLEAR:gv_processing_context ,gv_ech_objtype.
endmethod.
ENDCLASS.
