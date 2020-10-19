class ZOTCCL_PRICE_CONDITION_LOAD definition
  public
  final
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .   " Message container

  methods CONSTRUCTOR .
  type-pools ABAP .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
  methods PROCESS_DATA
    importing
      !IM_INPUT type Z01OTCMT_PRICE_CONDITION .         " Proxy Structure (generated)
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional   " Registration and Restarting of FEH
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION      " Registration and Restarting of FEH
    raising
      resumable(CX_SAPPLCO_STANDARD_MSG_FAULT) .
  methods FEH_PREPARE
    importing
      !IM_INPUT type Z01OTCMT_PRICE_CONDITION .         " Proxy Structure (generated)
  PROTECTED SECTION.
private section.

  class-data ATTRV_ECH_ACTION type ref to ZOTCCL_PRICE_CONDITION_LOAD .      " Reference Interest Load
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG'. "#EC NOTEXT
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .   " Processing context of service implementation

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .   " Processing context of service implementation
ENDCLASS.



CLASS ZOTCCL_PRICE_CONDITION_LOAD IMPLEMENTATION.


  METHOD CONSTRUCTOR.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~CONSTRUCTOR                *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*

    CREATE OBJECT attrv_msg_container.



  ENDMETHOD. "constructor


METHOD feh_execute.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~FEH_EXECUTE                *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*


  DATA: lv_raise_exception TYPE xflag                       VALUE IS INITIAL, "New Input Values
        lref_registration  TYPE REF TO cl_feh_registration  VALUE IS INITIAL, "Registration and Restarting of FEH
        lref_cx_system     TYPE REF TO cx_ai_system_fault   VALUE IS INITIAL, "Application Integration: Technical Error
        lv_mtext           TYPE string                      VALUE IS INITIAL, "Text value
        li_bapiret         TYPE bapirettab                  VALUE IS INITIAL. "Table with BAPI Return Information

  FIELD-SYMBOLS  <lfs_feh_data> TYPE zca_feh_data. "FEH Line

  CONSTANTS      lc_msg_fault   TYPE  classname VALUE 'CX_SAPPLCO_STANDARD_MSG_FAULT'. " Reference type

  IF lines( attrv_feh_data ) > 0.

    IF im_ref_registration IS BOUND.
      CLEAR lv_raise_exception.
      lref_registration = im_ref_registration.
    ELSE. " ELSE -> IF im_ref_registration IS BOUND
      lv_raise_exception = abap_true.
      lref_registration = cl_feh_registration=>s_initialize( is_single = space ).
    ENDIF. " IF im_ref_registration IS BOUND

    TRY.
**Process all the FEH data
        READ TABLE attrv_feh_data ASSIGNING <lfs_feh_data>
                                  INDEX 1.

        IF sy-subrc = 0.

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
        ENDIF. " IF sy-subrc = 0

      CATCH cx_ai_system_fault INTO lref_cx_system.
        lv_mtext = lref_cx_system->get_text( ).
        MESSAGE x026(bs_soa_common) WITH lv_mtext. "System error in the ForwardError Handling: &1
    ENDTRY.

    FREE attrv_feh_data.

**Raise Exception

    IF lv_raise_exception = abap_true.
 "Please raise the same exception in the proxy method definition
      CALL METHOD cl_proxy_fault=>raise(
        EXPORTING
          exception_class_name = lc_msg_fault
          bapireturn_tab       = li_bapiret ).

    ENDIF. " IF lv_raise_exception = abap_true
  ENDIF. " IF lines( attrv_feh_data ) > 0
ENDMETHOD. "feh_execute


  METHOD FEH_PREPARE.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~FEH_PREPARE                *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
* 27-Oct-2016 MTHATHA   E1DK919349  Defect#4928 Object key change based*
*                                   on interface                       *
*&---------------------------------------------------------------------*

    DATA:lwa_feh_data         TYPE zca_feh_data                VALUE IS INITIAL, "FEH Line
         lwa_ech_main_object  TYPE ech_str_object              VALUE IS INITIAL, "Object of Business Process
         li_applmsg           TYPE applmsgtab                  VALUE IS INITIAL, "Return Table for Messages
** Lr_data is used to in reference to proxy, so it can not be avoided
         lr_data              TYPE REF TO data                 VALUE IS INITIAL, "Class
         lv_objkey            TYPE ech_dte_objkey              VALUE IS INITIAL, "Object Key
         lwa_bapiret          TYPE bapiret2                    VALUE IS INITIAL. "Return Parameter

    FIELD-SYMBOLS: <lfs_appl_msg> TYPE applmsg. "Return Structure for Messages

    CONSTANTS:lc_one              TYPE ech_dte_objcat VALUE '1', "Object Category
*--Begin of changes for defect 4928 by mthatha
*              lc_obj              TYPE char13         VALUE 'OTC_IDD_0203'.   "Object Key
              lc_gap               TYPE char3          VALUE 'GAP',          " Gap of type CHAR3
              lc_obj_ppm           TYPE char13         VALUE 'OTC_IDD_0042', " Obj_ppm of type CHAR13
              lc_obj_gap           TYPE char13         VALUE 'OTC_IDD_0203'. "Object Key
*--End of changes for defect 4928 by mthatha

*--Begin of changes for defect 4928 by mthatha
*    CONCATENATE lc_obj
*                im_input-mt_price_condition-header-sender
*           INTO lv_objkey SEPARATED BY space.
    if im_input-mt_price_condition-header-sender eq lc_GAP.
      CONCATENATE lc_obj_gap
                  im_input-mt_price_condition-header-sender
             INTO lv_objkey SEPARATED BY space.
    else. " ELSE -> if im_input-mt_price_condition-header-sender eq lc_GAP
      CONCATENATE lc_obj_ppm
                  im_input-mt_price_condition-header-sender
             INTO lv_objkey SEPARATED BY space.
    endif. " if im_input-mt_price_condition-header-sender eq lc_GAP
*--End of changes for defect 4928 by mthatha

* The error category should depends on the actually error not below testing category
    lwa_feh_data-error_category  = attrv_msg_container->get_err_category( ).
    lwa_ech_main_object-objcat   = lc_one.
    lwa_ech_main_object-objtype  = me->attrv_objtype.
    lwa_ech_main_object-objkey   = lv_objkey.
    lwa_feh_data-main_object     = lwa_ech_main_object.

    GET REFERENCE OF im_input INTO lr_data.
    IF sy-subrc EQ 0.
      lwa_feh_data-single_bo_ref = lr_data.
    ENDIF. " IF sy-subrc EQ 0

    li_applmsg = attrv_msg_container->get_appl_messages( ).

    LOOP AT li_applmsg ASSIGNING <lfs_appl_msg>.
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
    lwa_feh_data-main_message = attrv_msg_container->get_main_error( ).

* To Populate Main message
    READ TABLE lwa_feh_data-all_messages INDEX 1 INTO lwa_feh_data-main_message.
    IF sy-subrc NE 0.
      CLEAR lwa_feh_data-main_message.
    ENDIF. " IF sy-subrc NE 0

    APPEND lwa_feh_data TO attrv_feh_data.
    CLEAR lwa_feh_data.

  ENDMETHOD. "METH_INST_PUB_FEH_PREPARE


  METHOD HAS_ERROR.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~HAS_ERROR                  *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*

    re_result = attrv_msg_container->has_error( ).
  ENDMETHOD. "has_error


  METHOD IF_ECH_ACTION~FAIL.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~FAIL                       *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*

    CONSTANTS  : lc_fail TYPE  bs_soa_siw_dte_proc_context VALUE 'FAIL'. " Processing context of service implementation

    CLEAR e_execution_failed.
    CLEAR e_return_message.

    me->initialize( im_id_processing_context = lc_fail ).

**Set the status to failed in FEH
    CALL METHOD cl_feh_registration=>s_fail
      EXPORTING
        i_data             = i_data
      IMPORTING
        e_execution_failed = e_execution_failed
        e_return_message   = e_return_message.

  ENDMETHOD. "if_ech_action~fail


  METHOD IF_ECH_ACTION~FINALIZE_AFTER_RETRY_ERROR.
  ENDMETHOD. "IF_ECH_ACTION~FINALIZE_AFTER_RETRY_ERROR


  METHOD IF_ECH_ACTION~FINISH.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~FINISH                     *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*
    CONSTANTS : lc_finish TYPE bs_soa_siw_dte_proc_context  VALUE 'FINISH'. " Processing context of service implementation

    CLEAR e_execution_failed.
    CLEAR e_return_message.

    me->initialize( im_id_processing_context = lc_finish ).

**Set the status to finish in FEH
    CALL METHOD cl_feh_registration=>s_finish
      EXPORTING
        i_data             = i_data
      IMPORTING
        e_execution_failed = e_execution_failed
        e_return_message   = e_return_message.

  ENDMETHOD. "IF_ECH_ACTION~FINISH


  METHOD IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR.
  ENDMETHOD. "IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR


  METHOD IF_ECH_ACTION~RETRY.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~RETRY                      *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*

**This method needs to be implemented to trigger the reprocessing of a message.
*The message will be called if Restart in Monitoring and Error Handling is
*clicked or if Repeat in Error  and  Conflict is selected

    DATA: lref_feh_registration  TYPE REF TO cl_feh_registration           VALUE IS INITIAL, "Registration and Restarting of FEH
          lx_input               TYPE        Z01OTCMT_PRICE_CONDITION VALUE IS INITIAL. "Inbound Message type for IDD0203

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
    me->process_data( lx_input ).

**If still, there is error
    IF me->has_error( ) = abap_true.
      me->feh_execute( im_ref_registration = lref_feh_registration ).
    ENDIF. " IF me->has_error( ) = abap_true

**Update the FEH
    lref_feh_registration->resolve_retry( ).
  ENDMETHOD. "if_ech_action~retry


  METHOD IF_ECH_ACTION~S_CREATE.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~S_CREATE                   *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*
**This Generate Instance
    IF NOT attrv_ech_action IS BOUND.
      CREATE OBJECT attrv_ech_action.
    ENDIF. " IF NOT attrv_ech_action IS BOUND
    r_action_class = attrv_ech_action. "Class
  ENDMETHOD. "if_ech_action~s_create


  METHOD INITIALIZE.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~INITIALIZE                 *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
*&---------------------------------------------------------------------*

    CONSTANTS : lc_retry   TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',    "Processing context of service implementation
                lc_fail    TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',     "Processing context of service implementation
                lc_finish  TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH',   "Processing context of service implementation
                lc_objtype TYPE ech_dte_objtype             VALUE 'BUS2144' . "Object Type

**Call the refresh method message container class.
    attrv_msg_container->refresh( ).

**me->refresh( ).
    attrv_pro_context = im_id_processing_context.

**Check the Processing Context
    IF attrv_pro_context EQ lc_retry OR
       attrv_pro_context EQ lc_fail OR
       attrv_pro_context EQ lc_finish.
      FREE attrv_feh_data.
    ENDIF. " IF attrv_pro_context EQ lc_retry OR

    attrv_objtype = lc_objtype.

  ENDMETHOD. "INITIALIZE


  method process_data.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul,Pallavi Gupta                               *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0203*
* 21-Jun-2016 U024571   E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
* 13-Aug-2016 MTHATHA   E1DK919349  D3_CRC#0047 Overlap Price          *
* 28-Oct-2016 APAUL     E1DK919349  D3_Defect_5606   When GAp quoting  *
*                                    system sends back to SAP a price  *
*                                    of 0, the 0 price for the         *
*                                    customer/ material should be      *
*                                    mapped to the Condition type ZM01 *
*                                    (not ZB00).                       *
* 07-Dec-2016 MTHATHA  E1DK919349  D3_Defect_6907 ZF01 update issue    *
* 01-Jan-2017 MTHATHA  E1DK919349  D3_eztrac turnoff through EMI       *
* 02-08-2017  MTHATHA  E1DK919349  Defect#9539 Handling Dump in GAP Int*
*&---------------------------------------------------------------------*

* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL
    data: lwa_proxy_in_header     type z01otcdt_price_condition_heade ,   " Proxy Structure (generated)
          li_proxy_in_item        type z01otcdt_price_condition_i_tab ,
          li_proxy_in_item_tmp2   type standard table of lty_item ,
          li_proxy_in_mvke        type standard table of lty_mvke ,
          li_proxy_in_knvv        type standard table of lty_knvv ,
          li_proxy_in_tcurc       type standard table of lty_tcurc ,
          li_item_sele            type standard table of lty_item ,
          li_bapicondct           type standard table of bapicondct,      " BAPI struct. for condition tables (corresponds to COND_RECS)
          li_bapicondhd           type standard table of bapicondhd,      " BAPI Structure of KONH with English Field Names
          li_bapicondit           type standard table of bapicondit,      " BAPI Structure of KONP with English Field Names
          li_bapicondqs           type standard table of bapicondqs,      " BAPI Structure of KONM with English Field Names
          li_bapicondvs           type standard table of bapicondvs,      " BAPI Structure of KONW with English Field Names
          li_bapiret2             type standard table of bapiret2,        " Return Parameter
          li_bapiknumhs           type standard table of bapiknumhs,      " BAPI Structure for Assignment of KNUMHs
          li_mem_initial          type standard table of cnd_mem_initial, " Conditions: Buffer for Initial Upload
          li_constants            type standard table of zdev_enh_status, " Enhancement Status
          li_mvke                 type standard table of lty_mvke,        " MVKE table
          li_knvv                 type standard table of lty_knvv ,
          li_con_945              type standard table of lty_con_945,     " Condition Table
          li_con_946              type standard table of lty_con_946,     " Condition Table
          li_con_935              type standard table of lty_con_935,     " Condition Table
          li_con_005              type standard table of lty_con_005,     " Condition Table
          li_tcurc                type standard table of lty_tcurc,
          li_mara                 type standard table of lty_mara,
          li_temp_mara            type standard table of lty_mara,
          lwa_temp_mara           type lty_mara,
          lwa_mvke                type lty_mvke,                          " Sales Data for Material
          lwa_knvv                type lty_knvv,                          " Customer data for sales
          lwa_bapicondct          type bapicondct,                        " BAPI struct. for condition tables (corresponds to COND_RECS)
          lwa_bapicondhd          type bapicondhd,                        " BAPI Structure of KONH with English Field Names
          lwa_bapicondit          type bapicondit,                        " BAPI Structure of KONP with English Field Names
          lwa_bapiret2            type bapiret2,                          " Return Parameter
          lwa_item                type lty_item ,                         " Items
          lwa_tcurc               type lty_tcurc,
          lwa_text_create         type lty_text_create,
          lv_kunnr                type kunnr_v,                           " Customer number
          lv_matnr                type matnr,                             " Material Number
          lv_kschl                type kschl,                             " Condition Type
          lv_kotabnr              type kotabnr ,                          " Condition table
          lv_skip                 type char1,                             " Skip of type CHAR1
          lv_commit_fail          type char1,                             " No commit
          lv_physically_del       type xfeld        ,                     " Checkbox
          lwa_line                type  tline   ,                         " SAPscript: Text Lines
          li_text_create          type standard table of lty_text_create,
          li_line                 type standard table of    tline ,       " SAPscript: Text Lines
          lv_count                type i,                                 " Count
          lv_date                 type datum,                             " Date
* FEH related  declaration
         lref_oref               type ref to cx_root                      value is initial, "Abstract Superclass for All Global Exceptions
         lref_server_cntxt       type ref to if_ws_server_context         value is initial, "Proxy Server Context
         lref_wsprotocol_msg_id  type ref to if_wsprotocol_message_id     value is initial, "XI and WS: Read Message ID
         lref_protocol           type ref to if_wsprotocol                value is initial, "ABAP Proxies: Available Protocols
         lref_cx_root            type ref to cx_root                      value is initial, "Abstract Superclass for All Global Exceptions
         li_sxmspdata            type standard table of sxmspdata         initial size 0,   "Archive for Message Extract
         lwa_sxmspdata           type sxmspdata                           value is initial, "Archive for Message Extract
         lwa_bapi_msg            type bapiret2                            value is initial, "Return Parameter
         lv_protocol_name        type string                              value is initial, "Protocol Name
         lv_xml_message_id       type sxmsmguid                           value is initial, "XI: Message ID
         lv_text                 type string                              value is initial, "String
* <--- Begin of Insert for CR#D3_0047 by MTHATHA
         li_konh                 type table of  konh,                " Conditions (Header)
         li_konp                 type table of konp,                 " Conditions (Item)
         lwa_konh                type konh,                          " Conditions (Header)
         lwa_konp                type konp,                          " Conditions (Item)
         lwa_task                type vkon_task_key,                 " Admin. and Appl. (Task) of Condition Technique
         li_messages             type cond_mnt_message_t,
         li_messages1            type cond_mnt_message_t,
         lwa_message             type cond_mnt_message,              " Condition Maintenance: Message Structure
         lv_subrc                type cond_mnt_result,               " Result of Condition Maintenance
         lwa_price_data          type price_details,                 " Inbound proxy price details
         lv_handle               type sytabix,                       " Index of Internal Tables
         lwa_komg                type komg,                          " Allowed Fields for Condition Structures
         li_selection            type cl_cond_tab_sel=>cond_rngs_t,
         lv_vakey                type konh-vakey,                    " Variable key 100 bytes
         lv_temp_knumh_mem1      type char060,                       " Knumh_mem1(60) of type Character
         lv_knumh                type konh-knumh value '0000000000', " Condition record number
         lv_modno                type char12,                        " Modno(12) of type Character
         lwa_record              type cond_mnt_record_data,          " Condition Maintenance: Condition Record (Key and Data)
         lv_recno                type syloopc,                       " Visible Lines of a Step Loop
         lv_idx                  type sy-tabix,                      " Index of Internal Tables
         li_record_keys          type cond_mnt_record_key_t,
         lwa_record_key          type cond_mnt_record_key,           " Condition Maintenance: ID and Key of a Condition Record
         lwa_selection           type line of cl_cond_tab_sel=>cond_rngs_t,
         lr_cond_utils           type ref to cl_cond_mnt_util_a,     " Utilities for Price Maintenance
         lv_current_number1      type char04,                        " Current_number1(4) of type Character
         lv_kbetr                type kbetr_kond,                    " Rate (condition amount or percentage) where no scale exists
* <--- End of Insert for CR#D3_0047 by MTHATHA
* <--- End of Insert for D3_OTC_IDD_0203 by APAUL
* <--- Begin of Insert for D3_OTC_IDD_0042 by U024571
         lv_id                   type tdid,     " Text ID
         lv_fname                type tdobname, " Name
         li_t685                 type standard table of lty_t685,
         li_tvko                 type standard table of lty_tvko,
         li_tvtw                 type standard table of lty_tvtw,
         li_kna1                 type standard table of lty_kna1,
         li_temp                 type z01otcdt_price_condition_i_tab,
* <--- End of Insert for D3_OTC_IDD_0042 by U024571
* ---> Begin of Insert Defect# D3_5606 by APAUL
         li_con_005_zm01         type standard table of lty_con_005. " Condition Table
* ---> End of Insert Defect# D3_5606 by APAUL


* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL
* Constants
    constants:
            lc_enh_name        type z_enhancement   value 'OTC_IDD_0203', " Enhancement No.
            lc_null            type z_criteria      value 'NULL',         " Constant table.
            lc_matnr           type z_criteria      value 'MATNR',        " Enh. Criteria
            lc_sender_gap      type z_criteria      value 'SENDER_GAP',   " Enh. Criteria
            lc_sender_ppm      type z_criteria      value 'SENDER_PPM',   " Enh. Criteria
* ---> Begin of Insert eztrac by mthatha
            lc_eztrac_gap      type z_criteria      value 'EZTRAC_GAP', " Enh. Criteria
            lc_eztrac_ppm      type z_criteria      value 'EZTRAC_PPM', " Enh. Criteria
* ---> End of Insert eztrac by mthatha
            lc_kschl_zb00      type z_criteria      value 'KSCHL_ZB00', " Enh. Criteria
            lc_kschl_zf01      type z_criteria      value 'KSCHL_ZF01', " Enh. Criteria
* ---> Begin of Insert Defect# D3_5606 by APAUL
            lc_kschl_zm01      type z_criteria      value 'KSCHL_ZM01', " Enh. Criteria
            lc_kbetr           type z_criteria      value 'KBETR'     , " Enh. Criteria
            lc_konwa           type konwa           value '%'         , " Rate unit (currency or percentage)
            lc_op_type_u       type char1           value 'U',          "  Update
* ---> End of Insert Defect# D3_5606 by APAUL
            lc_kschl_zppm      type z_criteria      value 'KSCHL_ZPPM',               " Enh. Criteria
            lc_text_procedure  type z_criteria      value 'TEXT_DETERMINE_PROCEDURE', " Enh. Criteria
            lc_id              type z_criteria      value 'TEXT_ID',                  " Enh. Criteria
            lc_bukrs_vkorg     type z_criteria      value 'BUKRS_VKORG'   ,           " Enh. Criteria
            lc_945             type kotabnr         value '945'  ,                    " Condition table
            lc_946             type kotabnr         value '946'  ,                    " Condition table
            lc_935             type kotabnr         value '935'  ,                    " Condition table
            lc_911             type kotabnr         value '911'  ,                    " Condition table
            lc_005             type kotabnr         value '005'  ,                    " Condition table
            lc_del_op          type msgfn           value '003'  ,                    " Function
            lc_ins_op          type msgfn           value '009',                      " Function
            lc_cond_ins        type knumh           value '$000000001',               " Condition record number
            lc_msg             type symsgno         value '000',                      "Message Number
            lc_msg_197         type symsgno         value '197',                      "Message Number
            lc_msg_198         type symsgno         value '198',                      "Message Number
            lc_msg_199         type symsgno         value '199',                      "Message Number
            lc_msg_200         type symsgno         value '200',                      "Message Number
            lc_msg_201         type symsgno         value '201',                      "Message Number
            lc_msg_202         type symsgno         value '202',                      " Message Number
            lc_msg_203         type symsgno         value '203',                      "Message Number
            lc_msg_204         type symsgno         value '204',                      "Message Number
            lc_msg_205         type symsgno         value '205',                      "Message Number
            lc_msg_213         type symsgno         value '213',                      "Message Number
            lc_msg_214         type symsgno         value '214',                      "Message Number
            lc_msg_282         type symsgno         value '282',                      "Message Number
            lc_msg_215         type symsgno         value '215',                      "Message Number
            lc_msg_216         type symsgno         value '216',                      "Message Number
            lc_msg_217         type symsgno         value '217',                      "Message Number
            lc_error           type char1           value 'E',                        "Error
            lc_message         type char24          value 'IF_WSPROTOCOL_MESSAGE_ID', "XI: Message ID
            lc_sender          type sxmspid         value 'SENDER',                   "Integration Engine: Pipeline ID
            lc_name            type sxms_extr_name  value 'B_DOCU',                   "Extractor Name
            lc_success         type char1           value 'S',                        "Success  message
            lc_abort           type char1           value 'A',                        "Abort  message
            lc_kopos           type kopos           value '01',                       " Sequential number of the condition
            lc_krech           type krech           value 'C',                        " Calculation type for condition
            lc_krech_a         type krech           value 'A',                        " Calculation type for condition
            lc_op_type         type char1           value 'I',                        " Insert
            lc_object          type tdobject        value 'KONP',                     " Texts: Application Object

* <--- Begin of Insert for CR#D3_0047 by MTHATHA
            lc_activity        type cond_mnt_activity value 'H',          " Conditions: Maintenance Activity
            lc_dolaar          type char2             value '$$',         " Dolaar of type CHAR2
            lc_temp_knumh      type char10            value 'TEMP_KNUMH', " Temp_knumh of type CHAR10
            lc_kappl           type kappl             value 'V',          " Application
* <--- End of Insert for CR#D3_0047 by MTHATHA
* <--- End of Insert for D3_OTC_IDD_0203 by APAUL
* <--- Begin of Insert for D3_OTC_IDD_0042 by U024571
            lc_msg_206         type symsgno         value '206', "Message Number
            lc_msg_207         type symsgno         value '207', "Message Number
            lc_msg_208         type symsgno         value '208', "Message Number
            lc_msg_209         type symsgno         value '209', "Message Number
            lc_msg_210         type symsgno         value '210', "Message Number
            lc_msg_211         type symsgno         value '211', "Message Number
            lc_msg_212         type symsgno         value '212'. "Message Number
* <--- End of Insert for D3_OTC_IDD_0042 by U024571

* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL
* Field Symbols
    field-symbols  : <lfs_proxy_in_item>     type z01otcdt_price_condition_item  ,  " Proxy Structure (generated)
                     <lfs_constants>         type zdev_enh_status                 , " Enhancement Status
                     <lfs_bapiret2>          type bapiret2 ,                        " Return Parameter
                     <lfs_con_945>           type lty_con_945,                      " Condition  table
                     <lfs_con_946>           type lty_con_946,                      " Condition  table
                     <lfs_con_935>           type lty_con_935,                      " Condition  table
                     <lfs_con_005>           type lty_con_005,                      " Condition  table
                     <lfs_text_create>       type lty_text_create,
* <--- End of Insert for D3_OTC_IDD_0203 by APAUL

* <--- Begin of Insert for CR#D3_0047 by MTHATHA
                    <lfs_record_key>         type cond_mnt_record_key, " Condition Maintenance: ID and Key of a Condition Record
* <--- End of Insert for CR#D3_0047 by MTHATHA
* <--- Begin of Insert for D3_OTC_IDD_0042 by U024571
                     <lfs_kna1>              type lty_kna1.
* <--- End of Insert for D3_OTC_IDD_0042 by U024571

* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL
    lwa_proxy_in_header = im_input-mt_price_condition-header.
    li_proxy_in_item = im_input-mt_price_condition-item[].


    try.
**Initialize FEH message container
        me->initialize( ).
      catch cx_root into lref_oref.
        lv_text                 = lref_oref->get_text( ).
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg.
        lwa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    endtry.

* Sender must not initial
    if lwa_proxy_in_header-sender is  initial.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_197.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      clear lwa_bapi_msg .

    else. " ELSE -> if lwa_proxy_in_header-sender is initial


*  Deletion record should process first
* <--- Begin of  Delete for CR#D3_0047 by MTHATHA
*      SORT li_proxy_in_item  BY loevm_ko DESCENDING .
* <--- End  of Delete for CR#D3_0047 by MTHATHA
* <--- Begin of Insert for CR#D3_0047  by MTHATHA
      sort li_proxy_in_item  by loevm_ko descending datab ascending.
* <--- End of Insert for CR#D3_0047 by MTHATHA


* Get file name from Constant table
      call function 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        exporting
          iv_enhancement_no = lc_enh_name
        tables
          tt_enh_status     = li_constants.
      if li_constants[] is not initial.
* Check EMI activated or not
        read table  li_constants
                    with key criteria =  lc_null
                             active = abap_true
                             transporting no fields.
        if sy-subrc is initial.
* <--- Begin of Insert for D3_Defect#9539 by MTHATHA
*          read table  li_constants
*                      with key criteria =    lc_sender_gap
*                               sel_low  =    lwa_proxy_in_header-sender
*                               active = abap_true
*                               transporting no fields.
** If its send from GAP
*          if sy-subrc is initial .
* <--- End of Insert for D3_Defect#9539 by MTHATHA
          if li_proxy_in_item is not initial.

* Populate selection table
            loop at  li_proxy_in_item assigning <lfs_proxy_in_item>.


* Populate Sales organisation details from country  code
              read table  li_constants assigning <lfs_constants>
                          with key criteria =      lc_bukrs_vkorg
                                   sel_low  =    <lfs_proxy_in_item>-vkorg
                                   active = abap_true.
              if sy-subrc is initial.
                <lfs_proxy_in_item>-vkorg = <lfs_constants>-sel_high .


* Popuate sold to party and ship to party

                if <lfs_proxy_in_item>-kunnr  is  not initial .
                  call function 'CONVERSION_EXIT_ALPHA_INPUT'
                    exporting
                      input  = <lfs_proxy_in_item>-kunnr
                    importing
                      output = <lfs_proxy_in_item>-kunnr.
                endif. " if <lfs_proxy_in_item>-kunnr is not initial

                if <lfs_proxy_in_item>-kunwe   is  not initial .
                  call function 'CONVERSION_EXIT_ALPHA_INPUT'
                    exporting
                      input  = <lfs_proxy_in_item>-kunwe
                    importing
                      output = <lfs_proxy_in_item>-kunwe.
                endif. " if <lfs_proxy_in_item>-kunwe is not initial


                if <lfs_proxy_in_item>-loevm_ko  is initial.
* Populate MVKE selection table
                  lwa_mvke-matnr   = <lfs_proxy_in_item>-matnr .
                  lwa_mvke-vkorg   = <lfs_proxy_in_item>-vkorg .
                  lwa_mvke-vtweg   = <lfs_proxy_in_item>-vtweg .
                  append  lwa_mvke to li_proxy_in_mvke.
                  clear lwa_mvke .

* Populate Currency table
                  lwa_tcurc-waers =  <lfs_proxy_in_item>-konwa .
                  append  lwa_tcurc to li_proxy_in_tcurc.
                  clear lwa_tcurc   .

* Populate KNVV selection table for  Sold to party
                  if <lfs_proxy_in_item>-kunnr  is   not initial.
                    lwa_knvv-kunnr   = <lfs_proxy_in_item>-kunnr .
                    lwa_knvv-vkorg   = <lfs_proxy_in_item>-vkorg .
                    lwa_knvv-vtweg   = <lfs_proxy_in_item>-vtweg .
                    append  lwa_knvv to li_proxy_in_knvv.
                    clear lwa_knvv .
                  endif. " if <lfs_proxy_in_item>-kunnr is not initial

* Populate KNVV selection table for Ship to Party
                  if <lfs_proxy_in_item>-kunwe  is   not initial.
                    lwa_knvv-kunnr   = <lfs_proxy_in_item>-kunwe .
                    lwa_knvv-vkorg   = <lfs_proxy_in_item>-vkorg .
                    lwa_knvv-vtweg   = <lfs_proxy_in_item>-vtweg .
                    append  lwa_knvv to li_proxy_in_knvv.
                    clear lwa_knvv  .
                  endif. " if <lfs_proxy_in_item>-kunwe is not initial
                endif. " if <lfs_proxy_in_item>-loevm_ko is initial

* Popoulate selection table for  condition
                lwa_item-vkorg  = <lfs_proxy_in_item>-vkorg .
                lwa_item-vtweg  = <lfs_proxy_in_item>-vtweg .
                lwa_item-kunnr  = <lfs_proxy_in_item>-kunnr .
                lwa_item-kunwe  = <lfs_proxy_in_item>-kunwe .
                lwa_item-matnr  = <lfs_proxy_in_item>-matnr .
                lwa_item-kbetr  = <lfs_proxy_in_item>-kbetr .
                lwa_item-konwa  = <lfs_proxy_in_item>-konwa .
                lwa_item-kmein  = <lfs_proxy_in_item>-kmein .
                lwa_item-kpein  = <lfs_proxy_in_item>-kpein .
                lwa_item-loevm_ko	=	<lfs_proxy_in_item>-loevm_ko .
                lwa_item-datbi  = <lfs_proxy_in_item>-datbi .
                lwa_item-datab  = <lfs_proxy_in_item>-datab .
                lwa_item-ztext  = <lfs_proxy_in_item>-ztext .
                append lwa_item to li_item_sele.

                clear  lwa_item .

              else. " ELSE -> if sy-subrc is initial

* If Sales organisation not found for country code , populate error message in FEH

                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg_200.
                lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-vkorg.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                clear:  lwa_bapi_msg     ,
               <lfs_proxy_in_item>-vkorg .

              endif. " if sy-subrc is initial

* Validation of To date
              lv_date = <lfs_proxy_in_item>-datbi .
              call function 'DATE_CHECK_PLAUSIBILITY'
                exporting
                  date                      = lv_date
                exceptions
                  plausibility_check_failed = 1
                  others                    = 2.
              if sy-subrc <> 0.
                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg_213.
                lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-datbi.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                clear:  lwa_bapi_msg     ,
               <lfs_proxy_in_item>-datbi ,
               lv_date.
              endif. " if sy-subrc <> 0


* Validation of From Date
              lv_date = <lfs_proxy_in_item>-datab .
              call function 'DATE_CHECK_PLAUSIBILITY'
                exporting
                  date                      = lv_date
                exceptions
                  plausibility_check_failed = 1
                  others                    = 2.
              if sy-subrc <> 0.
                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg_214.
                lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-datab.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                clear:  lwa_bapi_msg     ,
               <lfs_proxy_in_item>-datab ,
               lv_date.
              endif. " if sy-subrc <> 0


            endloop . " loop at li_proxy_in_item assigning <lfs_proxy_in_item>

* Delete  item for  which no sales organisation, Date found
            delete li_proxy_in_item where vkorg   is initial .
            delete li_proxy_in_item where datab   is initial .
            delete li_proxy_in_item where datbi   is initial .


* Get the entries  from MVKE table to validate  material and sales organisation
            sort    li_proxy_in_mvke  by matnr vkorg  vtweg.
            delete adjacent duplicates from li_proxy_in_mvke comparing matnr vkorg  vtweg .

            if li_proxy_in_mvke  is not  initial .
              select matnr " Material Number
                     vkorg " Sales Organization
                     vtweg " Distribution Channel
              from   mvke  " Sales Data for Material
              into table li_mvke
              for all entries in   li_proxy_in_mvke
              where matnr = li_proxy_in_mvke-matnr
              and  vkorg = li_proxy_in_mvke-vkorg
              and  vtweg = li_proxy_in_mvke-vtweg  .
*        If found
              if sy-subrc is   initial .
                sort li_mvke by matnr vkorg vtweg.
              endif. " if sy-subrc is initial
              free:  li_proxy_in_mvke .
            endif. " if li_proxy_in_mvke is not initial


* Get the entries  from MVKE table to validate  material and sales organisation
            sort    li_proxy_in_tcurc  by waers.
            delete adjacent duplicates from li_proxy_in_tcurc comparing waers .

            if li_proxy_in_tcurc  is not  initial .
              select waers " Material Number
              from   tcurc " Sales Data for Material
              into table li_tcurc
              for all entries in   li_proxy_in_tcurc
              where waers = li_proxy_in_tcurc-waers   .
*        If found
              if sy-subrc is   initial .
                sort li_tcurc by waers.
              endif. " if sy-subrc is initial
              free:  li_proxy_in_tcurc .
            endif. " if li_proxy_in_tcurc is not initial


* Get the entries  from MVKE table to validate  material and sales organisation
            sort    li_proxy_in_knvv   by kunnr  vkorg  vtweg.
            delete adjacent duplicates from li_proxy_in_knvv comparing kunnr  vkorg  vtweg .
*This select is for Validation only- Subset of the keys is required to be validated. hence
*only that subset is selected by adding the same  the same subset in the where clause .
*Hence no data loss  will happen.So  full set is not required to be selected for this FAE
            if li_proxy_in_knvv   is not  initial .
              select kunnr " Material Number
                     vkorg " Sales Organization
                     vtweg " Distribution Channel
              from   knvv  " Sales Data for Material
              into table li_knvv
              for all entries in   li_proxy_in_knvv
              where kunnr  = li_proxy_in_knvv-kunnr
              and  vkorg   = li_proxy_in_knvv-vkorg
              and  vtweg   = li_proxy_in_knvv-vtweg  .

*        If found
              if sy-subrc is   initial .
                sort li_knvv by kunnr vkorg vtweg.
              endif. " if sy-subrc is initial
              free:  li_proxy_in_knvv .
            endif. " if li_proxy_in_knvv is not initial


* Check the material is in EMI table, if it is there , then it is condition type ZF01, else ZB00
            read table  li_constants assigning <lfs_constants>
             with key criteria =  lc_matnr
                       active = abap_true.
            if sy-subrc is initial.
              lv_matnr = <lfs_constants>-sel_low.
              read table  li_constants assigning <lfs_constants>
                          with key criteria =    lc_kschl_zf01
                                   active = abap_true.
              if sy-subrc is  initial.
                lv_kschl = <lfs_constants>-sel_low.

* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 946 will select.
                li_proxy_in_item_tmp2  = li_item_sele   .

                delete li_proxy_in_item_tmp2 where loevm_ko is initial.
                delete li_proxy_in_item_tmp2 where matnr ne lv_matnr.
                delete li_proxy_in_item_tmp2 where kunwe is not initial .
                sort li_proxy_in_item_tmp2 by vkorg
                                              vtweg
                                              kunnr
                                              datbi.
                delete adjacent duplicates from li_proxy_in_item_tmp2
                                   comparing  vkorg
                                              vtweg
                                              kunnr
                                              datbi.


                if li_proxy_in_item_tmp2 is not initial.
                  select kappl " Application
                         kschl " Condition type
                         vkorg " Sales Organization
                         vtweg " Distribution Channel
                         kunag " Sold-to party
                         datbi " Validity end date of the condition record
                         knumh " Condition record number
                     from a946 " Customer/Material
                     into table  li_con_946
                    for all entries in li_proxy_in_item_tmp2
                    where    kappl =  lwa_proxy_in_header-kappl
                    and      kschl =  lv_kschl
                    and      vkorg =  li_proxy_in_item_tmp2-vkorg
                    and      vtweg =  li_proxy_in_item_tmp2-vtweg
                    and      kunag =  li_proxy_in_item_tmp2-kunnr
                    and      datbi =  li_proxy_in_item_tmp2-datbi.
                  if sy-subrc is initial.
                    sort   li_con_946  by kappl kschl vkorg vtweg kunag datbi .
                  endif. " if sy-subrc is initial
                  clear  li_proxy_in_item_tmp2    .
                endif. " if li_proxy_in_item_tmp2 is not initial


* Select all the condition record no from condition table for delete operation. If ship to party is there, then condition 945 will select.
                li_proxy_in_item_tmp2  = li_item_sele   .

                delete li_proxy_in_item_tmp2 where loevm_ko is initial.
                delete li_proxy_in_item_tmp2 where matnr ne lv_matnr.
                delete li_proxy_in_item_tmp2 where kunwe is initial.
                sort li_proxy_in_item_tmp2 by vkorg
                                              vtweg
                                              kunnr
                                              kunwe
                                              datbi.
                delete adjacent duplicates from li_proxy_in_item_tmp2
                                   comparing  vkorg
                                              vtweg
                                              kunnr
                                              kunwe
                                              datbi.

                if li_proxy_in_item_tmp2 is not initial.

                  select  kappl " Application
                          kschl " Condition type
                          vkorg " Sales Organization
                          vtweg " Distribution Channel
                          kunag " Sold-to party
                          kunwe " Ship-to party
                          datbi " Validity end date of the condition record
                          knumh " Condition record number
                     from a945  " Customer/Material
                     into table  li_con_945
                    for all entries in li_proxy_in_item_tmp2
                    where    kappl =  lwa_proxy_in_header-kappl
                    and      kschl =  lv_kschl
                    and      vkorg =  li_proxy_in_item_tmp2-vkorg
                    and      vtweg =  li_proxy_in_item_tmp2-vtweg
                    and      kunag =  li_proxy_in_item_tmp2-kunnr
                    and      kunwe =  li_proxy_in_item_tmp2-kunwe
                    and      datbi =  li_proxy_in_item_tmp2-datbi.
                  if sy-subrc is initial.
                    sort   li_con_945  by kappl kschl vkorg vtweg kunag kunwe datbi .
                  endif. " if sy-subrc is initial
                endif . " if li_proxy_in_item_tmp2 is not initial
              endif. " if sy-subrc is initial

              read table  li_constants assigning <lfs_constants>
                        with key criteria =    lc_kschl_zb00
                                 active = abap_true.
              if sy-subrc is  initial.

                lv_kschl = <lfs_constants>-sel_low.
                clear li_proxy_in_item_tmp2 .
* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 005 will select.
                li_proxy_in_item_tmp2  = li_item_sele   .
* ---> Begin of Insert Defect# D3_5606 by APAUL
*  Consider only item which  value is not initial
                delete li_proxy_in_item_tmp2 where kbetr eq '0.00'.
* --->  End of Insert Defect# D3_5606 by APAUL

                delete li_proxy_in_item_tmp2 where loevm_ko is initial.
                delete li_proxy_in_item_tmp2 where matnr eq lv_matnr.
                delete li_proxy_in_item_tmp2 where kunwe is not initial .
                sort li_proxy_in_item_tmp2 by vkorg
                                              vtweg
                                              kunnr
                                              matnr
                                              datbi.
                delete adjacent duplicates from li_proxy_in_item_tmp2
                                   comparing  vkorg
                                              vtweg
                                              kunnr
                                              matnr
                                              datbi.
                if li_proxy_in_item_tmp2 is not initial.

                  select kappl " Application
                         kschl " Condition type
                         vkorg " Sales Organization
                         vtweg " Distribution Channel
                         kunnr " Customer number
                         matnr " Material Number
                         datbi " Validity end date of the condition record
                         knumh " Condition record number
                     from a005 " Customer/Material
                     into table  li_con_005
                    for all entries in li_proxy_in_item_tmp2
                    where    kappl =  lwa_proxy_in_header-kappl
                    and      kschl =  lv_kschl
                    and      vkorg =  li_proxy_in_item_tmp2-vkorg
                    and      vtweg =  li_proxy_in_item_tmp2-vtweg
                    and      kunnr =  li_proxy_in_item_tmp2-kunnr
                    and      matnr =  li_proxy_in_item_tmp2-matnr
                    and      datbi =  li_proxy_in_item_tmp2-datbi.
                  if sy-subrc is initial.
                    sort   li_con_005  by kappl kschl vkorg vtweg  kunnr matnr  datbi .
                  endif. " if sy-subrc is initial
                  clear li_proxy_in_item_tmp2    .

                endif. " if li_proxy_in_item_tmp2 is not initial

* Select all the condition record no from condition table for delete operation. If ship to party is there, then condition 935 will select.
                li_proxy_in_item_tmp2  = li_item_sele   .

                delete li_proxy_in_item_tmp2 where loevm_ko is initial.
                delete li_proxy_in_item_tmp2 where matnr eq lv_matnr.
                delete li_proxy_in_item_tmp2 where kunwe is initial.
                sort li_proxy_in_item_tmp2 by vkorg
                                              vtweg
                                              kunnr
                                              kunwe
                                              matnr
                                              datbi.
                delete adjacent duplicates from li_proxy_in_item_tmp2
                                   comparing  vkorg
                                              vtweg
                                              kunnr
                                              kunwe
                                              matnr
                                              datbi.

                if li_proxy_in_item_tmp2 is not initial.

                  select kappl " Application
                         kschl " Condition type
                         vkorg " Sales Organization
                         vtweg " Distribution Channel
                         kunag " Sold-to party
                         kunwe " Ship-to party
                         matnr " Material Number
                         datbi " Validity end date of the condition record
                         knumh " Condition record number
                     from a935 " Customer/Material
                     into table  li_con_935
                    for all entries in li_proxy_in_item_tmp2
                    where    kappl =  lwa_proxy_in_header-kappl
                    and      kschl =  lv_kschl
                    and      vkorg =  li_proxy_in_item_tmp2-vkorg
                    and      vtweg =  li_proxy_in_item_tmp2-vtweg
                    and      kunag =  li_proxy_in_item_tmp2-kunnr
                    and      kunwe =  li_proxy_in_item_tmp2-kunwe
                    and      matnr =  li_proxy_in_item_tmp2-matnr
                    and      datbi =  li_proxy_in_item_tmp2-datbi.
                  if sy-subrc is initial.
                    sort   li_con_935  by kappl kschl vkorg vtweg kunag   kunwe matnr  datbi .
                  endif. " if sy-subrc is initial
                endif. " if li_proxy_in_item_tmp2 is not initial
              endif . " if sy-subrc is initial


* ---> Begin of Insert Defect# D3_5606 by APAUL
* Populate condition type for ZM01
              read table  li_constants assigning <lfs_constants>
                        with key criteria =    lc_kschl_zm01
                                 active = abap_true.
              if sy-subrc is  initial.

                lv_kschl = <lfs_constants>-sel_low.
                clear li_proxy_in_item_tmp2 .
* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 005 will select.
                li_proxy_in_item_tmp2  = li_item_sele   .
                delete li_proxy_in_item_tmp2 where kbetr ne 0 .
                delete li_proxy_in_item_tmp2 where loevm_ko is initial.
                delete li_proxy_in_item_tmp2 where matnr eq lv_matnr.
                delete li_proxy_in_item_tmp2 where kunwe is not initial .
                sort li_proxy_in_item_tmp2 by vkorg
                                              vtweg
                                              kunnr
                                              matnr
                                              datbi.
                delete adjacent duplicates from li_proxy_in_item_tmp2
                                   comparing  vkorg
                                              vtweg
                                              kunnr
                                              matnr
                                              datbi.
                if li_proxy_in_item_tmp2 is not initial.

                  select kappl " Application
                         kschl " Condition type
                         vkorg " Sales Organization
                         vtweg " Distribution Channel
                         kunnr " Customer number
                         matnr " Material Number
                         datbi " Validity end date of the condition record
                         knumh " Condition record number
                     from a005 " Customer/Material
                     into table  li_con_005_zm01
                    for all entries in li_proxy_in_item_tmp2
                    where    kappl =  lwa_proxy_in_header-kappl
                    and      kschl =  lv_kschl
                    and      vkorg =  li_proxy_in_item_tmp2-vkorg
                    and      vtweg =  li_proxy_in_item_tmp2-vtweg
                    and      kunnr =  li_proxy_in_item_tmp2-kunnr
                    and      matnr =  li_proxy_in_item_tmp2-matnr
                    and      datbi =  li_proxy_in_item_tmp2-datbi.
                  if sy-subrc is initial.
                    sort   li_con_005_zm01  by kappl kschl vkorg vtweg  kunnr matnr  datbi .
                  endif. " if sy-subrc is initial
                  clear li_proxy_in_item_tmp2    .

                endif. " if li_proxy_in_item_tmp2 is not initial
              endif . " if sy-subrc is initial

* --->  End of Insert Defect# D3_5606 by APAUL


            endif. " if sy-subrc is initial

            free: li_proxy_in_item_tmp2,
                  li_item_sele.

* Select the data, find the condition table and do the operation as required through BAPI.

            loop at  li_proxy_in_item assigning <lfs_proxy_in_item>.
* ---> Begin of Insert  Defect# D3_6907 by APAUL
              lv_kbetr = <lfs_proxy_in_item>-kbetr.
* ---> End of Insert  Defect# D3_6907 by APAUL
* If material is there, then condition type is ZF01
              read table  li_constants assigning <lfs_constants>
                          with key criteria =  lc_matnr
                                   sel_low = <lfs_proxy_in_item>-matnr
                                   active = abap_true.
              if sy-subrc is initial.

                read table  li_constants assigning <lfs_constants>
                            with key criteria =    lc_kschl_zf01
                                     active = abap_true.
                if sy-subrc is  initial.
                  lv_kschl = <lfs_constants>-sel_low.

* If sold to party and ship to party is there then 945 condition  table
                  if <lfs_proxy_in_item>-kunnr is  not initial and
                     <lfs_proxy_in_item>-kunwe is not initial.

                    lv_kotabnr  = lc_945.
* If sold to party is there  and ship to party is not there then 946 condition  table

                  elseif <lfs_proxy_in_item>-kunnr is not initial  and
                         <lfs_proxy_in_item>-kunwe is initial.

                    lv_kotabnr  = lc_946 .
                  endif. " if <lfs_proxy_in_item>-kunnr is not initial and
                endif. " if sy-subrc is initial

* ---> Begin of Insert  Defect# D3_5606 by APAUL
* If KBETER is initial  and ship to party not provide, populate condition type ZM01
* ---> Begin of Insert  Defect# D3_6907 by APAUL
*                elseif <lfs_proxy_in_item>-kbetr eq '0.00' and
*                 elseif ( <lfs_proxy_in_item>-kbetr eq '0.' or <lfs_proxy_in_item>-kbetr eq '0.00') and
              elseif lv_kbetr eq 0 and
* ---> End of Insert  Defect# D3_6907 by APAUL
                    <lfs_proxy_in_item>-kunwe is initial.

* If material is not  there, then condition type is  ZM01

                read table  li_constants assigning <lfs_constants>
                            with key criteria =    lc_kschl_zm01
                                     active = abap_true.
                if sy-subrc eq 0.

                  lv_kschl = <lfs_constants>-sel_low.
                  lv_kotabnr  = lc_005 .
                endif. " if sy-subrc eq 0

* ---> End of Insert Defect# D3_5606 by APAUL

              else . " ELSE -> if sy-subrc is initial
* If material is not  there, then condition type is ZB00

                read table  li_constants assigning <lfs_constants>
                            with key criteria =    lc_kschl_zb00
                                     active = abap_true.
                if sy-subrc eq 0.

                  lv_kschl = <lfs_constants>-sel_low.
* If sold to party and ship to party is there then 935 condition  table
                  if <lfs_proxy_in_item>-kunnr is  not initial and
                     <lfs_proxy_in_item>-kunwe is not initial.

                    lv_kotabnr  = lc_935.

* If sold to party is there  and ship to party is not there then 005 condition  table
                  elseif <lfs_proxy_in_item>-kunnr is not initial  and
                         <lfs_proxy_in_item>-kunwe is initial.

                    lv_kotabnr  = lc_005 .

* If sold to party is tnot here  and ship to party is there then 911 condition  table
                  elseif  <lfs_proxy_in_item>-kunnr is initial  and
                          <lfs_proxy_in_item>-kunwe is not initial.

                    lv_kotabnr  = lc_911 .

                  endif. " if <lfs_proxy_in_item>-kunnr is not initial and
                endif. " if sy-subrc eq 0
              endif. " if sy-subrc is initial

* <--- Begin of Insert for D3_Defect#9539 by MTHATHA
              if lv_kotabnr is initial.
                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg_282.
                lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-kunnr.
                lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-kunwe.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                clear:lwa_bapi_msg.
              endif. " if lv_kotabnr is initial
* Prepare FEH error
              if me->has_error( ) = abap_true.
                me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
                me->feh_prepare( im_input ).
                continue.
              endif. " if me->has_error( ) = abap_true
* <--- End of Insert for D3_Defect#9539 by MTHATHA

* Populate the Condition table
              lwa_bapicondct-table_no = lv_kotabnr .
              lwa_bapicondhd-table_no = lv_kotabnr.

* Populate the VARKEY
              case lv_kotabnr .
                when lc_945 .
                  concatenate     <lfs_proxy_in_item>-vkorg
                   <lfs_proxy_in_item>-vtweg
                   <lfs_proxy_in_item>-kunnr
                   into lwa_bapicondct-varkey.

                  lwa_bapicondct-varkey+16 =  <lfs_proxy_in_item>-kunwe .

                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.

                when lc_946.
                  concatenate     <lfs_proxy_in_item>-vkorg
                                  <lfs_proxy_in_item>-vtweg
                                  <lfs_proxy_in_item>-kunnr
                               into lwa_bapicondct-varkey.

                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.


                when lc_935.
                  concatenate     <lfs_proxy_in_item>-vkorg
                                  <lfs_proxy_in_item>-vtweg
                                  <lfs_proxy_in_item>-kunnr
                                  into lwa_bapicondct-varkey.

                  lwa_bapicondct-varkey+16 =  <lfs_proxy_in_item>-kunwe .
                  lwa_bapicondct-varkey+26 =  <lfs_proxy_in_item>-matnr.

                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.

                when lc_005.
                  concatenate     <lfs_proxy_in_item>-vkorg
                                  <lfs_proxy_in_item>-vtweg
                                  <lfs_proxy_in_item>-kunnr
                                  into lwa_bapicondct-varkey.

                  lwa_bapicondct-varkey+16 = <lfs_proxy_in_item>-matnr.

                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.

                when lc_911.
                  concatenate     <lfs_proxy_in_item>-vkorg
                                  <lfs_proxy_in_item>-vtweg
                                  <lfs_proxy_in_item>-kunwe
                                  into lwa_bapicondct-varkey.

                  lwa_bapicondct-varkey+16 =  <lfs_proxy_in_item>-matnr.

                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.

                when others .
*        Do nothing
              endcase .

              if <lfs_proxy_in_item>-loevm_ko   is initial.

* Check  Sales organsiation and material validation not in  MVKE table
                if lv_kotabnr eq lc_935 or
                   lv_kotabnr eq lc_005 .
                  read table li_mvke
                  with key  matnr  = <lfs_proxy_in_item>-matnr
                            vkorg  = <lfs_proxy_in_item>-vkorg
                            vtweg  = <lfs_proxy_in_item>-vtweg
                           transporting no fields
                            binary search .

                  if sy-subrc is  not  initial.
                    lv_commit_fail =  abap_true    .
                    lv_skip = abap_true.
                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                    lwa_bapi_msg-id         = attrc_msgid.
                    lwa_bapi_msg-number     = lc_msg_198.
                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-matnr.
                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-vkorg.
                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                  endif. " if sy-subrc is not initial
                endif. " if lv_kotabnr eq lc_935 or

* Check  Sold  to Party and Sales  Organisation validation not in  KNVV table

                if <lfs_proxy_in_item>-kunnr is not initial .

                  read table li_knvv
                  with key  kunnr  = <lfs_proxy_in_item>-kunnr
                            vkorg  = <lfs_proxy_in_item>-vkorg
                            vtweg  = <lfs_proxy_in_item>-vtweg
                           transporting no fields
                            binary search .

                  if sy-subrc is  not  initial.
                    lv_commit_fail =  abap_true    .
                    lv_skip = abap_true.
                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                    lwa_bapi_msg-id         = attrc_msgid.
                    lwa_bapi_msg-number     = lc_msg_216.
                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-kunnr .
                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-vkorg.
                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

                  endif. " if sy-subrc is not initial
                endif. " if <lfs_proxy_in_item>-kunnr is not initial

* Check  Ship to Party and Sales  Organisation validation not in  KNVV table
                if  <lfs_proxy_in_item>-kunwe is   not initial.
                  read table li_knvv
                  with key  kunnr  = <lfs_proxy_in_item>-kunwe
                            vkorg  = <lfs_proxy_in_item>-vkorg
                            vtweg  = <lfs_proxy_in_item>-vtweg
                           transporting no fields
                            binary search .
                  if sy-subrc is  not  initial.
                    lv_commit_fail =  abap_true    .
                    lv_skip = abap_true.
                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                    lwa_bapi_msg-id         = attrc_msgid.
                    lwa_bapi_msg-number     = lc_msg_215.
                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-kunwe .
                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-vkorg.
                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                  endif. " if sy-subrc is not initial
                endif. " if <lfs_proxy_in_item>-kunwe is not initial


*  Currency key  validation

                read table li_tcurc
                with key  waers  = <lfs_proxy_in_item>-konwa
                         transporting no fields
                          binary search .

                if sy-subrc is  not  initial.
                  lv_commit_fail =  abap_true    .
                  lv_skip = abap_true.
                  lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                  lwa_bapi_msg-id         = attrc_msgid.
                  lwa_bapi_msg-number     = lc_msg_217.
                  lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-konwa .
                  me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

                endif. " if sy-subrc is not initial
              endif. " if <lfs_proxy_in_item>-loevm_ko is initial



* If Condition records need to  insert
              if <lfs_proxy_in_item>-loevm_ko is  initial.

                lwa_bapicondct-operation = lc_ins_op.
                lwa_bapicondct-cond_no =  lc_cond_ins.
                lwa_bapicondhd-operation = lc_ins_op.
                lwa_bapicondhd-cond_no = lc_cond_ins.
                lwa_bapicondit-operation = lc_ins_op.
                lwa_bapicondit-cond_no = lc_cond_ins .
                lwa_bapicondit-cond_count = lc_kopos.
                lwa_bapicondhd-created_by = sy-uname.
                lwa_bapicondhd-creat_date = sy-datum.
                lwa_bapicondhd-valid_from = <lfs_proxy_in_item>-datab .
                lwa_bapicondhd-valid_to = <lfs_proxy_in_item>-datbi.

              else. " ELSE -> if <lfs_proxy_in_item>-loevm_ko is initial

* If Condition records need to delete
                case  lv_kotabnr  .
                  when lc_945.

                    read table li_con_945 assigning <lfs_con_945>
                               with key     kappl =  lwa_proxy_in_header-kappl
                                            kschl =  lv_kschl
                                            vkorg =  <lfs_proxy_in_item>-vkorg
                                            vtweg =  <lfs_proxy_in_item>-vtweg
                                            kunag =  <lfs_proxy_in_item>-kunnr
                                            kunwe =  <lfs_proxy_in_item>-kunwe
                                            datbi =  <lfs_proxy_in_item>-datbi
                                    binary search.
* If condition record not found, skip it
                    if sy-subrc is not initial .
                      lv_commit_fail =  abap_true    .
                      lv_skip   = abap_true.
                      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                      lwa_bapi_msg-id         = attrc_msgid.
                      lwa_bapi_msg-number     = lc_msg_201.
                      lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

                    else. " ELSE -> if sy-subrc is not initial
                      lwa_bapicondct-cond_no =   <lfs_con_945>-knumh.
                      lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
                      lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
                    endif. " if sy-subrc is not initial

                  when  lc_946.

                    read table li_con_946 assigning <lfs_con_946>
                               with key     kappl =  lwa_proxy_in_header-kappl
                                                kschl =  lv_kschl
                                                vkorg =  <lfs_proxy_in_item>-vkorg
                                                vtweg =  <lfs_proxy_in_item>-vtweg
                                                kunag =  <lfs_proxy_in_item>-kunnr
                                                datbi =  <lfs_proxy_in_item>-datbi
                                                 binary search.
* If condition record not found, skip it
                    if sy-subrc is not initial .
                      lv_commit_fail =  abap_true    .
                      lv_skip   = abap_true.
                      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                      lwa_bapi_msg-id         = attrc_msgid.
                      lwa_bapi_msg-number     = lc_msg_202.
                      lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                    else. " ELSE -> if sy-subrc is not initial
                      lwa_bapicondct-cond_no =   <lfs_con_946>-knumh.
                      lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
                      lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.


                    endif. " if sy-subrc is not initial

                  when lc_935 .

                    read table li_con_935 assigning <lfs_con_935>
                               with key     kappl =  lwa_proxy_in_header-kappl
                                                kschl =  lv_kschl
                                                vkorg =  <lfs_proxy_in_item>-vkorg
                                                vtweg =  <lfs_proxy_in_item>-vtweg
                                                kunag =  <lfs_proxy_in_item>-kunnr
                                                kunwe =  <lfs_proxy_in_item>-kunwe
                                                matnr  = <lfs_proxy_in_item>-matnr
                                                datbi =  <lfs_proxy_in_item>-datbi
                                                 binary search.

* If condition record not found, skip it
                    if sy-subrc is not initial .
                      lv_commit_fail          = abap_true    .
                      lv_skip                 = abap_true.
                      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                      lwa_bapi_msg-id         = attrc_msgid.
                      lwa_bapi_msg-number     = lc_msg_203.
                      lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

                    else. " ELSE -> if sy-subrc is not initial
                      lwa_bapicondct-cond_no =   <lfs_con_935>-knumh.
                      lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
                      lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
                    endif. " if sy-subrc is not initial

                  when lc_005 .
* ---> Begin of Insert Defect# D3_5606 by APAUL
* If KBETER is not initial, then it is ZB00
*                      if <lfs_proxy_in_item>-kbetr  ne '0.00' or <lfs_proxy_in_item>-kbetr  ne '0,00' or
* ---> Begin of Insert Defect# D3_6907 by APAUL
*                      if  lv_kbetr  ne '0.00'   or lv_kbetr ne '0,00'.
                    if  lv_kbetr  ne '0.00'.
* ---> End of Insert Defect# D3_6907 by APAUL
* ---> End of Insert Defect# D3_5606 by APAUL

                      read table li_con_005 assigning <lfs_con_005>
                                 with key         kappl =  lwa_proxy_in_header-kappl
                                                  kschl =  lv_kschl
                                                  vkorg =  <lfs_proxy_in_item>-vkorg
                                                  vtweg =  <lfs_proxy_in_item>-vtweg
                                                  kunnr =  <lfs_proxy_in_item>-kunnr
                                                  matnr =  <lfs_proxy_in_item>-matnr
                                                  datbi =  <lfs_proxy_in_item>-datbi
                                                   binary search.

* If condition record not found, skip it
                      if sy-subrc is not initial .
                        lv_commit_fail =  abap_true    .
                        lv_skip   = abap_true.
                        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                        lwa_bapi_msg-id         = attrc_msgid.
                        lwa_bapi_msg-number     = lc_msg_204.
                        lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
                        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                      else. " ELSE -> if sy-subrc is not initial

                        lwa_bapicondct-cond_no =   <lfs_con_005>-knumh.
                        lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
                        lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
                      endif. " if sy-subrc is not initial

* ---> Begin of Insert Defect# D3_5606 by APAUL
* select from ZM01 table

                    else. " ELSE -> if lv_kbetr ne '0 00'

                      read table li_con_005_zm01  assigning <lfs_con_005>
                                 with key         kappl =  lwa_proxy_in_header-kappl
                                                  kschl =  lv_kschl
                                                  vkorg =  <lfs_proxy_in_item>-vkorg
                                                  vtweg =  <lfs_proxy_in_item>-vtweg
                                                  kunnr =  <lfs_proxy_in_item>-kunnr
                                                  matnr =  <lfs_proxy_in_item>-matnr
                                                  datbi =  <lfs_proxy_in_item>-datbi
                                                   binary search.

* If condition record not found, skip it
                      if sy-subrc is not initial .
                        lv_commit_fail =  abap_true    .
                        lv_skip   = abap_true.
                        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                        lwa_bapi_msg-id         = attrc_msgid.
                        lwa_bapi_msg-number     = lc_msg_204.
                        lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
                        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                      else. " ELSE -> if sy-subrc is not initial

                        lwa_bapicondct-cond_no =   <lfs_con_005>-knumh.
                        lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
                        lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
                      endif. " if sy-subrc is not initial
                    endif . " if lv_kbetr ne '0 00'

* ---> End of Insert Defect# D3_5606 by APAUL


                  when  others.
* Do   nothing

                endcase.

                lwa_bapicondct-operation = lc_del_op.
                lwa_bapicondhd-operation = lc_del_op.
                lwa_bapicondit-operation = lc_del_op.
                lv_physically_del = abap_false.
              endif. " if <lfs_proxy_in_item>-loevm_ko is initial

              lwa_bapicondct-cond_usage = lwa_proxy_in_header-kvewe.
              lwa_bapicondct-applicatio = lwa_proxy_in_header-kappl.
              lwa_bapicondct-cond_type = lv_kschl .
              lwa_bapicondct-valid_to = <lfs_proxy_in_item>-datbi.
              lwa_bapicondct-valid_from = <lfs_proxy_in_item>-datab.
              lwa_bapicondhd-cond_usage = lwa_proxy_in_header-kvewe .
              lwa_bapicondhd-applicatio = lwa_proxy_in_header-kappl .
              lwa_bapicondhd-cond_type = lv_kschl .
              lwa_bapicondit-applicatio = lwa_proxy_in_header-kappl.
              lwa_bapicondit-cond_count = lc_kopos.
              lwa_bapicondit-cond_type = lv_kschl.
              lwa_bapicondit-cond_p_unt = <lfs_proxy_in_item>-kpein.
              lwa_bapicondit-cond_unit = <lfs_proxy_in_item>-kmein.
              lwa_bapicondit-calctypcon = lc_krech .
              lwa_bapicondit-cond_value = <lfs_proxy_in_item>-kbetr .
              lwa_bapicondit-condcurr = <lfs_proxy_in_item>-konwa.


              if lv_skip ne abap_true.
* Populate Bapi table
                append  lwa_bapicondct  to li_bapicondct .
                append lwa_bapicondhd to li_bapicondhd   .
                append lwa_bapicondit to li_bapicondit   .

                try.
* <--- Begin of Insert for CR#D3_0047 by MTHATHA
                    if <lfs_proxy_in_item>-loevm_ko is not initial.
* <--- End of Insert for CR#D3_0047 by MTHATHA
* This BAPI has been call inside the loop because we have to catch the condition no upon isert to update the condition text
** init maintenance session
                      lwa_task-kvewe = lwa_proxy_in_header-kvewe.
                      lwa_task-kappl = lwa_proxy_in_header-kappl.

* <--- Begin of Insert for CR#D3_0047  by MTHATHA
*  Initialize condition maintenance
                      try.
                          call function 'COND_MNT_INIT'
                            exporting
                              is_task      = lwa_task
                              iv_condtype  = lv_kschl
                              iv_condtable = lv_kotabnr
                              iv_activity  = lc_activity
                            importing
                              ev_handle    = lv_handle
                              et_selection = li_selection.
                        catch cx_cond_mnt_session.

                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages1.
                          clear lwa_message.
                      endtry.
* <--- End of Insert for CR#D3_0047 by MTHATHA

                      call function 'BAPI_PRICES_CONDITIONS'
                        exporting
                          pi_physical_deletion = lv_physically_del
                        tables
                          ti_bapicondct        = li_bapicondct
                          ti_bapicondhd        = li_bapicondhd
                          ti_bapicondit        = li_bapicondit
                          ti_bapicondqs        = li_bapicondqs
                          ti_bapicondvs        = li_bapicondvs
                          to_bapiret2          = li_bapiret2
                          to_bapiknumhs        = li_bapiknumhs
                          to_mem_initial       = li_mem_initial
                        exceptions
                          update_error         = 1
                          others               = 2.
                      if sy-subrc eq 0.
                        read table li_bapiret2  with key  type  = lc_error transporting  no fields . " Bapiret2 with ke of type
                        if sy-subrc ne 0.

                          read table li_bapiret2  with key  type  = lc_abort transporting  no fields . " Bapiret2 with ke of type
                          if sy-subrc ne 0.
                            call function 'BAPI_TRANSACTION_COMMIT'
                              exporting
                                wait = abap_true.
* <--- Begin of Insert for CR#D3_0047  by MTHATHA
*--End the Session
                            try.
                                call function 'COND_MNT_END'
                                  exporting
                                    iv_handle          = lv_handle
                                    iv_ignore_dataloss = abap_true
                                  importing
                                    et_messages        = li_messages.
                              catch cx_cond_mnt_session.
                                lwa_message-msgty = sy-msgty  .
                                lwa_message-msgid = sy-msgid   .
                                lwa_message-msgno = sy-msgno  .
                                lwa_message-msgv1 = sy-msgv1 .
                                lwa_message-msgv2 = sy-msgv2 .
                                lwa_message-msgv3 = sy-msgv3 .
                                lwa_message-msgv4 = sy-msgv4 .
                                append lwa_message to li_messages1.
                                clear lwa_message.
                            endtry.
                          endif. " if sy-subrc ne 0
                        endif. " if sy-subrc ne 0
                      else. " ELSE -> if sy-subrc eq 0
                        call function 'BAPI_TRANSACTION_ROLLBACK'.
                      endif. " if sy-subrc eq 0
* <--- End of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
* <--- Begin of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
                    else. " ELSE -> if <lfs_proxy_in_item>-loevm_ko is not initial

                      clear:lwa_price_data.
                      refresh:li_konh,li_konp.
*--Create object instance for condition utilities
                      create object lr_cond_utils.
                      clear:lwa_price_data.
                      lwa_price_data-vkorg   = <lfs_proxy_in_item>-vkorg.
                      lwa_price_data-vtweg   = <lfs_proxy_in_item>-vtweg.
                      lwa_price_data-datab   = <lfs_proxy_in_item>-datab.
                      lwa_price_data-datbi   = <lfs_proxy_in_item>-datbi.
* ---> Begin of Insert Defect# D3_5606 by APAUL
                      read table  li_constants assigning <lfs_constants>
                           with key criteria =    lc_kschl_zm01
                                    active = abap_true.
                      if sy-subrc is initial.
                        if lv_kschl = <lfs_constants>-sel_low.
* If KBETER is initial ,  then populate ZM01   else ZB00
*                            if <lfs_proxy_in_item>-kbetr = '0.00' or <lfs_proxy_in_item>-kbetr = '0,00'.
* ---> Begin of Insert Defect# D3_6907 by APAUL
                          if lv_kbetr = '0.00' or lv_kbetr = '0,00'.
* ---> End of Insert Defect# D3_6907 by APAUL
                            read table  li_constants assigning <lfs_constants>
                           with key criteria =    lc_kbetr
                                    active = abap_true.
                            if sy-subrc is  initial.
                              lwa_price_data-kbetr   =  <lfs_constants>-sel_low .
                              lwa_price_data-konwa   =  lc_konwa.
                            else. " ELSE -> if sy-subrc is initial
                              lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                              lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                            endif. " if sy-subrc is initial
                          else. " ELSE -> if lv_kbetr = '0 00' or lv_kbetr = '0,00'
                            lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                            lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                          endif. " if lv_kbetr = '0 00' or lv_kbetr = '0,00'
                        else. " ELSE -> if lv_kschl = <lfs_constants>-sel_low
                          lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                          lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                        endif      . " if lv_kschl = <lfs_constants>-sel_low
                      else. " ELSE -> if sy-subrc is initial
                        lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                        lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                      endif      . " if sy-subrc is initial
* ---> End of Insert Defect# D3_5606 by APAUL

* ---> Begin of Insert Defect# D3_6907 by APAUL
                      read table  li_constants assigning <lfs_constants>
                           with key criteria =    lc_kschl_zf01
                                    active = abap_true.
                      if sy-subrc is initial.
                        if lv_kschl = <lfs_constants>-sel_low.
* If KBETER is initial ,  then populate ZM01   else ZB00
*                            if <lfs_proxy_in_item>-kbetr = '0.00' or <lfs_proxy_in_item>-kbetr = '0,00'.
* ---> Begin of Insert Defect# D3_6907 by APAUL
                          if lv_kbetr = '0.00' or lv_kbetr = '0,00'.
* ---> End of Insert Defect# D3_6907 by APAUL
                            read table  li_constants assigning <lfs_constants>
                           with key criteria =    lc_kbetr
                                    active = abap_true.
                            if sy-subrc is  initial.
                              lwa_price_data-kbetr   =  <lfs_constants>-sel_low .
                              lwa_price_data-konwa   =  lc_konwa.
                            else. " ELSE -> if sy-subrc is initial
                              lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                              lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                            endif. " if sy-subrc is initial
                          else. " ELSE -> if lv_kbetr = '0 00' or lv_kbetr = '0,00'
                            if lwa_price_data-konwa is initial.
                              lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                              lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                            endif. " if lwa_price_data-konwa is initial
                          endif. " if lv_kbetr = '0 00' or lv_kbetr = '0,00'
                        else. " ELSE -> if lv_kschl = <lfs_constants>-sel_low
                          if lwa_price_data-konwa is initial.
                            lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                            lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                          endif. " if lwa_price_data-konwa is initial
                        endif      . " if lv_kschl = <lfs_constants>-sel_low
                      else. " ELSE -> if sy-subrc is initial
                        lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
                        lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
                      endif      . " if sy-subrc is initial
* ---> End of Insert Defect# D3_6907 by mthatha

* ---> Begin of  Delete Defect# D3_5606 by APAUL
*                         lwa_price_data-kbetr   = <lfs_proxy_in_item>-kbetr.
* ---> End of Delete Defect# D3_5606 by APAUL
                      lwa_price_data-kmein   = <lfs_proxy_in_item>-kmein.

* ---> Begin of Delete Defect# D3_5606 by APAUL
*                        lwa_price_data-konwa   = <lfs_proxy_in_item>-konwa.
* ---> End of  Delete Defect# D3_5606 by APAUL
                      lwa_price_data-kotabnr = lv_kotabnr.
                      lwa_price_data-kpein   = <lfs_proxy_in_item>-kpein.
                      lwa_price_data-kschl   = lv_kschl.
                      lwa_price_data-matnr   = <lfs_proxy_in_item>-matnr.
** init maintenance session
                      lwa_task-kvewe = lwa_proxy_in_header-kvewe.
                      lwa_task-kappl = lwa_proxy_in_header-kappl.
*  Initialize condition maintenance
                      try.
                          call function 'COND_MNT_INIT'
                            exporting
                              is_task      = lwa_task
                              iv_condtype  = lv_kschl
                              iv_condtable = lv_kotabnr
                              iv_activity  = lc_activity
                            importing
                              ev_handle    = lv_handle
                              et_selection = li_selection.
                        catch cx_cond_mnt_session.
                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages1.
                          clear lwa_message.
                      endtry.
** Calculate temporary condition record number
                      import lv_current_number1 to lv_current_number1 from memory id lv_temp_knumh_mem1.
                      if sy-subrc = 4.
                        lv_current_number1 = 0.
                      endif. " if sy-subrc = 4
                      lv_knumh(2) = lc_dolaar.
                      lv_current_number1 = lv_current_number1 + 1.
                      unpack lv_current_number1 to lv_knumh+2(8).
                      if lv_temp_knumh_mem1 is initial.
                        lv_modno = sy-modno.
                        concatenate lc_temp_knumh lv_modno into lv_temp_knumh_mem1.
                      endif. " if lv_temp_knumh_mem1 is initial
                      export lv_current_number1 from lv_current_number1 to memory id lv_temp_knumh_mem1.
*-Fill the details for condition record header
                      lwa_konh-knumh   = lv_knumh.
                      lwa_konh-ernam   = sy-uname.
                      lwa_konh-erdat   = sy-datlo.
                      lwa_konh-kvewe   = lwa_proxy_in_header-kvewe.
                      lwa_konh-kotabnr = lv_kotabnr.
                      lwa_konh-kappl   = lc_kappl.
                      lwa_konh-kschl   = lv_kschl.
                      lwa_konh-vakey   = lwa_bapicondhd-varkey.
                      lwa_konh-datab   = lwa_price_data-datab.
                      lwa_konh-datbi   = lwa_price_data-datbi.
                      append lwa_konh to li_konh.
                      clear lwa_konh.
*-Fill the details for condition record item
                      lwa_konp-knumh = lv_knumh.
                      lwa_konp-kopos = lc_kopos.
                      lwa_konp-kschl = lv_kschl.
*--Check the condition type for ZF01

                      read table  li_constants assigning <lfs_constants>
                       with key criteria =    lc_kschl_zf01
                                active = abap_true.
                      if sy-subrc is  initial.
                        if lwa_konp-kschl = <lfs_constants>-sel_low.
*--Multiple amount * 10 and currency to space
                          lwa_konp-kbetr = lwa_price_data-kbetr * 10.
                          lwa_konp-krech = lc_krech_a.
                          lwa_konp-konwa = '%'.
                        else. " ELSE -> if lwa_konp-kschl = <lfs_constants>-sel_low
                          lwa_konp-kbetr = lwa_price_data-kbetr.
                          lwa_konp-krech = lc_krech.
                          lwa_konp-konwa = lwa_price_data-konwa.
                        endif. " if lwa_konp-kschl = <lfs_constants>-sel_low
                      endif. " if sy-subrc is initial
* ---> Begin of Insert Defect# D3_5606 by mthatha
* Populate the ZM01 with default value
                      read table  li_constants assigning <lfs_constants>
                       with key criteria =    lc_kschl_zm01
                                active = abap_true.
                      if sy-subrc is  initial.
                        if lwa_konp-kschl = <lfs_constants>-sel_low.
*--Multiple amount * 10 and currency to space
                          lwa_konp-kbetr = lwa_price_data-kbetr * 10.
                          lwa_konp-krech = lc_krech_a.
                          lwa_konp-konwa = '%'.
                        else. " ELSE -> if lwa_konp-kschl = <lfs_constants>-sel_low
* ---> Begin of Insert Defect# D3_6907 by mthatha
                          if lwa_konp-krech is initial.
* ---> End of Insert Defect# D3_6907 by mthatha
                            lwa_konp-kbetr = lwa_price_data-kbetr.
                            lwa_konp-krech = lc_krech.
                            lwa_konp-konwa = lwa_price_data-konwa.
* ---> Begin of Insert Defect# D3_6907 by mthatha
                          endif. " if lwa_konp-krech is initial
* ---> End of Insert Defect# D3_6907 by mthatha
                        endif. " if lwa_konp-kschl = <lfs_constants>-sel_low
                      endif. " if sy-subrc is initial
* ---> End of Insert Defect# D3_5606 by mthatha

                      lwa_konp-kappl = lwa_proxy_in_header-kappl.
                      lwa_konp-kschl = lv_kschl.
                      lwa_konp-kpein = lwa_price_data-kpein.
                      lwa_konp-kmein = lwa_price_data-kmein.
                      lwa_konp-kunnr = <lfs_proxy_in_item>-kunnr.

                      append lwa_konp to li_konp.
                      clear lwa_konp.
                      lwa_record-kotabnr = lwa_price_data-kotabnr .
                      lwa_record-kschl   = lwa_price_data-kschl   .
                      lwa_record-datbi   = lwa_price_data-datbi  .
                      lwa_record-datab   = lwa_price_data-datab   .

                      try.
                          call method lr_cond_utils->pack_datapart
                            exporting
                              it_konh = li_konh
                              it_konp = li_konp
                            receiving
                              result  = lwa_record-datapart.
                        catch cx_cond_datacontainer .
                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages1.
                          clear lwa_message.
                      endtry.
** start maintenance (create mode -> select records)
                      try.
                          call function 'COND_MNT_START'
                            exporting
                              iv_handle      = lv_handle
                              iv_seldate     = sy-datum
                              iv_vakey       = lwa_bapicondhd-varkey
                            importing
                              ev_subrc       = lv_subrc
                              et_messages    = li_messages
                              ev_recno       = lv_recno
                              et_record_keys = li_record_keys.
                        catch cx_cond_mnt_session.
                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages1.
                          clear lwa_message.
                      endtry.

                      append lines of li_messages to li_messages1.
** Insert condition record


                      lwa_record-kotabnr = lwa_price_data-kotabnr .
                      lwa_record-kschl   = lwa_price_data-kschl   .
                      lwa_record-datbi   = lwa_price_data-datbi  .
                      lwa_record-datab   = lwa_price_data-datab   .
                      lwa_record-vakey   = lwa_bapicondhd-varkey.
                      lwa_record-kvewe   = lwa_proxy_in_header-kvewe.
                      lwa_record-kappl  = lwa_proxy_in_header-kappl.
                      try.
                          call function 'COND_MNT_RECORD_PUT'
                            exporting
                              iv_handle        = lv_handle
                              iv_allow_overlap = abap_true
                              record_data      = lwa_record
                            importing
                              ev_rec_id        = lwa_record_key-record_id
                              ev_subrc         = lv_subrc
                              et_messages      = li_messages.
                        catch cx_cond_mnt_session.
                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages.
                          clear lwa_message.
                        catch cx_cond_mnt_record.

                          lwa_message-msgty = sy-msgty  .
                          lwa_message-msgid = sy-msgid   .
                          lwa_message-msgno = sy-msgno  .
                          lwa_message-msgv1 = sy-msgv1 .
                          lwa_message-msgv2 = sy-msgv2 .
                          lwa_message-msgv3 = sy-msgv3 .
                          lwa_message-msgv4 = sy-msgv4 .

                          append lwa_message to li_messages1.
                          clear lwa_message.
                      endtry.
                      append lines of li_messages to li_messages1.
                      if lv_subrc = 0.
** Save condition record
                        read table li_messages1 with key msgty = lc_error transporting no fields.
                        if sy-subrc <> 0. " Check any errors occured
                          read table li_messages1 with key msgty =  lc_abort  transporting no fields.
                          if sy-subrc <> 0. " Check any abend message issued
                            try.
                                call function 'COND_MNT_SAVE'
                                  exporting
                                    iv_handle      = lv_handle
                                  importing
                                    et_record_keys = li_record_keys
                                    et_messages    = li_messages.
                              catch cx_cond_mnt_session.
                                lwa_message-msgty = sy-msgty  .
                                lwa_message-msgid = sy-msgid   .
                                lwa_message-msgno = sy-msgno  .
                                lwa_message-msgv1 = sy-msgv1 .
                                lwa_message-msgv2 = sy-msgv2 .
                                lwa_message-msgv3 = sy-msgv3 .
                                lwa_message-msgv4 = sy-msgv4 .
                                append lwa_message to li_messages1.
                                clear lwa_message.
                            endtry.
                            wait up to 1 seconds.
                            append lines of li_messages to li_messages1.
                          endif. " if sy-subrc <> 0
                        endif. " if sy-subrc <> 0
                      else. " ELSE -> if lv_subrc = 0

                      endif. " if lv_subrc = 0
                      try.
                          call function 'COND_MNT_END'
                            exporting
                              iv_handle          = lv_handle
                              iv_ignore_dataloss = abap_true
                            importing
                              et_messages        = li_messages.
                        catch cx_cond_mnt_session.
                      endtry.
                      append lines of li_messages to li_messages1.

                      loop at li_messages1 into lwa_message.
                        lwa_bapiret2-type       = lwa_message-msgty.
                        lwa_bapiret2-id         = lwa_message-msgid.
                        lwa_bapiret2-number     = lwa_message-msgno.
                        lwa_bapiret2-message_v1 = lwa_message-msgv1.
                        lwa_bapiret2-message_v2 = lwa_message-msgv2.
                        lwa_bapiret2-message_v2 = lwa_message-msgv2.
                        lwa_bapiret2-message_v2 = lwa_message-msgv2.
                        append lwa_bapiret2 to li_bapiret2.
                        clear lwa_bapiret2.
                      endloop. " loop at li_messages1 into lwa_message

                    endif. " if <lfs_proxy_in_item>-loevm_ko is not initial
* <--- End of Insert for CR#D3_0047  by MTHATHA
*    If successfully updated,  then  Concition text updated for inserted  condition  record no
                    if sy-subrc eq  0.
                      read table li_bapiret2  with key  type  = lc_error transporting  no fields . " Bapiret2 with ke of type
                      if sy-subrc ne 0.

                        read table li_bapiret2  with key  type  = lc_abort transporting  no fields . " Bapiret2 with ke of type
                        if sy-subrc ne 0.
                          if <lfs_proxy_in_item>-ztext is not initial   .

                            read table  li_constants assigning <lfs_constants>
                                                      with key criteria =    lc_text_procedure
                                                               active = abap_true.
                            if sy-subrc is  initial.
                              read table li_bapiret2  assigning <lfs_bapiret2>  with key  type  = lc_success  . " Bapiret2 with ke of type
                              if sy-subrc eq 0.
* <--- Begin of Insert for CR#D3_0047  by MTHATHA
                                if <lfs_proxy_in_item>-loevm_ko is not initial.
* <--- End of Insert for CR#D3_0047  by MTHATHA
                                  if <lfs_bapiret2>-message_v3  eq  lc_op_type or
                                     <lfs_bapiret2>-message_v3  eq  lc_op_type_u  .
                                    concatenate <lfs_bapiret2>-message_v1 <lfs_constants>-sel_low into lwa_text_create-fname.
                                    lwa_text_create-cond_value = <lfs_bapiret2>-message_v1 .

                                  endif. " if <lfs_bapiret2>-message_v3 eq lc_op_type or

                                  read table  li_constants assigning <lfs_constants>
                                                            with key criteria =    lc_id
                                                                     active = abap_true.
                                  if sy-subrc is  initial.

                                    lwa_text_create-tdid   = <lfs_constants>-sel_low .
                                    lwa_text_create-tdline = <lfs_proxy_in_item>-ztext.
                                    append  lwa_text_create to li_text_create .

                                  endif. " if sy-subrc is initial
* <--- Begin of Insert for CR#D3_0047  by MTHATHA
                                else. " ELSE -> if <lfs_proxy_in_item>-loevm_ko is not initial
                                  read table li_record_keys assigning <lfs_record_key> index 1.
                                  if sy-subrc eq 0.
                                    concatenate <lfs_record_key>-knumh <lfs_constants>-sel_low into lwa_text_create-fname.
                                    lwa_text_create-cond_value = <lfs_record_key>-knumh.
                                  endif. " if sy-subrc eq 0

                                  read table  li_constants assigning <lfs_constants>
                                                            with key criteria =    lc_id
                                                                     active = abap_true.
                                  if sy-subrc is  initial.

                                    lwa_text_create-tdid   = <lfs_constants>-sel_low .
                                    lwa_text_create-tdline = <lfs_proxy_in_item>-ztext.
                                    append  lwa_text_create to li_text_create .

                                  endif. " if sy-subrc is initial
                                endif. " if <lfs_proxy_in_item>-loevm_ko is not initial
* <--- End of Insert for CR#D3_0047   by MTHATHA

* <--- Begin of Insert for CR#D3_0047    by MTHATHA
*                                  ENDIF. " IF <lfs_bapiret2>-message_v3 EQ lc_op_type
* <--- End of Insert for CR#D3_0047   by MTHATHA
                              endif. " if sy-subrc eq 0
                            endif. " if sy-subrc is initial
                          endif. " if <lfs_proxy_in_item>-ztext is not initial
                        else. " ELSE -> if sy-subrc ne 0

                          lv_commit_fail =  abap_true    .

                          loop at li_bapiret2 assigning <lfs_bapiret2>.
                            if <lfs_bapiret2>-type eq lc_error or
                               <lfs_bapiret2>-type eq lc_abort.
                              me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                            endif. " if <lfs_bapiret2>-type eq lc_error or
                          endloop. " loop at li_bapiret2 assigning <lfs_bapiret2>
                        endif. " if sy-subrc ne 0
                      else. " ELSE -> if sy-subrc ne 0

                        lv_commit_fail =  abap_true    .

                        loop at li_bapiret2 assigning <lfs_bapiret2>.
                          if <lfs_bapiret2>-type eq lc_error or
                            <lfs_bapiret2>-type eq lc_abort.
                            me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                          endif. " if <lfs_bapiret2>-type eq lc_error or
                        endloop. " loop at li_bapiret2 assigning <lfs_bapiret2>

                      endif. " if sy-subrc ne 0
                    endif. " if sy-subrc eq 0
                  catch cx_root into lref_oref.
                    lv_commit_fail =  abap_true    .
                    lv_text                 = lref_oref->get_text( ).
                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                    lwa_bapi_msg-id         = attrc_msgid.
                    lwa_bapi_msg-number     = lc_msg.
                    lwa_bapi_msg-message_v1 = lv_text.
                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

                endtry.
              endif. " if lv_skip ne abap_true

              clear: lv_skip,
                     lwa_bapicondct,
                     lwa_bapicondhd ,
                     lwa_bapicondit ,
                     lwa_text_create.

              clear:   li_bapicondct,
                       li_bapicondhd ,
                       li_bapicondit,
                       li_bapicondqs,
                       li_bapicondvs,
                       li_bapiret2,
                       li_bapiknumhs,
                       li_mem_initial.

            endloop. " loop at li_proxy_in_item assigning <lfs_proxy_in_item>

**If the Input data is updated successsfully then the link between the message processing and the
*buisness document is created.
            try .
                lv_protocol_name = lc_message.

**Class cl_proxy_access : To access ABAP proxy runtime objects without using a proxy instance
                call method cl_proxy_access=>get_server_context "Server Context
                  receiving
                    server_context = lref_server_cntxt.         "Server Context

**Method get_protocol :TO access the protocol class.
                call method lref_server_cntxt->get_protocol
                  exporting
                    protocol_name = lv_protocol_name "Protocol Name
                  receiving
                    protocol      = lref_protocol.   "Returns the Protocol Class

              catch cx_ai_system_fault into lref_oref.
                lv_commit_fail =  abap_true    .
                lv_text                 = lref_oref->get_text( ).
                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg.
                lwa_bapi_msg-message_v1 = lv_text.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
            endtry.

**Get a protocol instance for the protocol IF_WSPROTOCOL_MESSAGE_ID.
            try.
                lref_wsprotocol_msg_id ?= lref_protocol.
              catch cx_root into lref_oref.

                lv_commit_fail =  abap_true    .
                lv_text                 = lref_oref->get_text( ).
                lwa_bapi_msg-type       = zcacl_message_container=>c_error.
                lwa_bapi_msg-id         = attrc_msgid.
                lwa_bapi_msg-number     = lc_msg.
                lwa_bapi_msg-message_v1 = lv_text.
                me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
            endtry.

* If any error occured previously for any record, no record will be updated. It can be update from FEH reprocess .
* If no error occued,  all record witll be created .
            if   lv_commit_fail ne  abap_true    .

              call function 'BAPI_TRANSACTION_COMMIT'
                exporting
                  wait = abap_true.

              loop at li_text_create  assigning <lfs_text_create> .

                lwa_line-tdline = <lfs_text_create>-tdline  .
                append  lwa_line to li_line .

* Create condition text  in condition
                call function 'CREATE_TEXT'
                  exporting
                    fid       = <lfs_text_create>-tdid
                    flanguage = sy-langu
                    fname     = <lfs_text_create>-fname
                    fobject   = lc_object
                  tables
                    flines    = li_line
                  exceptions
                    no_init   = 1
                    no_save   = 2
                    others    = 3.
                if sy-subrc <> 0.
* Implement suitable error handling here
                  lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
                  lwa_bapi_msg-id         = attrc_msgid.
                  lwa_bapi_msg-number     = lc_msg_199.
                  lwa_bapi_msg-message_v1 = <lfs_text_create>-cond_value   .
                  me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                endif. " if sy-subrc <> 0

*To have the system return the message ID after the sender has sent a request message
*or the receiver has received a request message, use the method GET_MESSAGE_ID of this instance.
*This returns the ID using the parameter MESSAGE_ID of the type SXMSGUID.
                if lref_cx_root is not bound.
                  lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ). "XML-message ID determination
                endif. " if lref_cx_root is not bound


                if lv_xml_message_id is not initial.
**If the data is processed successfully but the file name is blank in Input data then the processing stops
                  lwa_sxmspdata-msgguid    =  lv_xml_message_id. "PI Message ID
                  lwa_sxmspdata-pid        =  lc_sender. "Default Value - Sender
                  lwa_sxmspdata-name       =  lc_name. "Buisness Document ( B_DOCU )
**The reason 1 is directly passed and not as constant because in SLIN the warning is coming as
**Text literal '1' must be converted to the numeric literal 1
*It is more efficient to enter the numeric literal 1 directly,
                  lv_count = lv_count + 1 .
                  lwa_sxmspdata-extr_count =  lv_count. "Default Value - 1
                  lwa_sxmspdata-value      =  <lfs_text_create>-cond_value. "Value
                  lwa_sxmspdata-method     =  lc_success. "S
                  append lwa_sxmspdata to li_sxmspdata.
                  clear lwa_sxmspdata.

* <--- Begin of Insert for eztrac emi by MTHATHA
* Check EMI activated or not
                  read table  li_constants
                              with key criteria =  lc_eztrac_gap
                                       sel_low  =  lwa_proxy_in_header-sender
                                       active = abap_true
                                       transporting no fields.
                  if sy-subrc eq 0.
* <--- End of Insert for eztrac emi by MTHATHA
*FM ZDEV_UPDATE_SXMSPDATA: To link message processing with the buisness document created
*After the link is set up succesfully with this FM , the table SXMSPDATA is updated
*with the details.
                    call function 'ZDEV_UPDATE_SXMSPDATA'
                      exporting
                        im_t_sxmspdata   = li_sxmspdata "Archive for Message Extract
                      exceptions
                        record_locked    = 1
                        data_not_updated = 2
                        others           = 3.

                    if sy-subrc <> 0.
**Add the error message in the message container
                      lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
                      lwa_bapi_msg-id         = attrc_msgid.
                      lwa_bapi_msg-number     = lc_msg_205.
                      lwa_bapi_msg-message_v1 = <lfs_text_create>-cond_value. "Value

                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
                    endif. " if sy-subrc <> 0
* <--- Begin of Insert for eztrac emi by MTHATHA
                  endif. " if sy-subrc eq 0
* <--- End of Insert for eztrac emi by MTHATHA
                endif. " if lv_xml_message_id is not initial

                clear: lwa_line,
                       li_line,
                       li_sxmspdata,
                       lwa_sxmspdata.

              endloop. " loop at li_text_create assigning <lfs_text_create>

            else. " ELSE -> if lv_commit_fail ne abap_true
              call function 'BAPI_TRANSACTION_ROLLBACK'
                .

            endif. " if lv_commit_fail ne abap_true
          endif. " if li_proxy_in_item is not initial

* <--- End of Insert for D3_OTC_IDD_0203 by APAUL
* <--- Begin of Insert for D3_OTC_IDD_0042 by U024571
*If its send from PPM
*        ELSEIF lwa_proxy_in_header-sender = 'PPM' .
* <--- Begin of Insert for D3_Defect#9539 by MTHATHA
*          elseif sy-subrc is not initial.
*            read table  li_constants assigning <lfs_constants>
*                      with key criteria =    lc_sender_ppm
*                               sel_low  =    lwa_proxy_in_header-sender
*                               active = abap_true.
** If condition type is ZPPM
*            if sy-subrc = 0.
*              read table  li_constants assigning <lfs_constants>
*              with key criteria =    lc_kschl_zppm
*                       active = abap_true.
*
*              if sy-subrc = 0.
*                clear lv_kschl.
*                lv_kschl = <lfs_constants>-sel_low.
*
*                clear li_temp_mara.
*                loop at li_proxy_in_item assigning <lfs_proxy_in_item>.
*
*                  if <lfs_proxy_in_item>-kunnr  is  not initial .
*                    call function 'CONVERSION_EXIT_ALPHA_INPUT'
*                      exporting
*                        input  = <lfs_proxy_in_item>-kunnr
*                      importing
*                        output = <lfs_proxy_in_item>-kunnr.
*                  endif. " if <lfs_proxy_in_item>-kunnr is not initial
*
**Populate Material from Item table to temp table for validating from MARA table
*                  if <lfs_proxy_in_item>-matnr is not initial.
*                    clear lwa_temp_mara.
*                    lwa_temp_mara-matnr = <lfs_proxy_in_item>-matnr.
*                    append lwa_temp_mara to li_temp_mara.
*                  endif. " if <lfs_proxy_in_item>-matnr is not initial
*                endloop. " loop at li_proxy_in_item assigning <lfs_proxy_in_item>
*
**Basic Validations for the file data
*                refresh : li_t685,
*                          li_tvko,
*                          li_tvtw,
*                          li_kna1,
*                          li_tcurc,
*                          li_mara.
**Condition Type validation
*                select kvewe " Usage of the condition table
*                       kappl " Application
*                       kschl " Condition Type
*                from   t685  " Conditions: Types
*                into table li_t685
*                  where kvewe = lwa_proxy_in_header-kvewe
*                  and   kappl = lwa_proxy_in_header-kappl
*                  and   kschl = lv_kschl.
*                if sy-subrc = 0.
*                  sort li_t685 by kvewe kappl kschl.
*                endif. " if sy-subrc = 0
*
*                li_temp = li_proxy_in_item.
*                sort li_temp by vkorg.
*                delete adjacent duplicates from li_temp comparing vkorg.
**Sales Org validation
*                if li_temp is not initial.
*                  select vkorg " Sales Organization
*                  from   tvko  " Organizational Unit: Sales Organizations
*                  into table li_tvko
*                    for all entries in li_temp
*                    where vkorg = li_temp-vkorg.
*                  if sy-subrc = 0.
*                    sort li_tvko by vkorg.
*                  endif. " if sy-subrc = 0
*                  free li_temp.
*                endif. " if li_temp is not initial
*
*                li_temp = li_proxy_in_item.
*                sort li_temp by vtweg.
*                delete adjacent duplicates from li_temp comparing vtweg.
**Distribution Channel validation
*                if li_temp is not initial.
*                  select vtweg " Distribution Channel
*                  from   tvtw  " Organizational Unit: Distribution Channels
*                  into table li_tvtw
*                    for all entries in li_temp
*                    where vtweg = li_temp-vtweg.
*                  if sy-subrc = 0.
*                    sort li_tvtw by vtweg.
*                  endif. " if sy-subrc = 0
*                  free li_temp.
*                endif. " if li_temp is not initial
*
*
*                li_temp = li_proxy_in_item.
*                sort li_temp by kunnr.
*                delete adjacent duplicates from li_temp comparing kunnr.
*                if li_temp is not initial.
**Customer number validation
*                  select  kunnr     " Customer Number
*                          aufsd     " Central order block for customer
*                          from kna1 " General Data in Customer Master
*                          into table li_kna1
*                    for all entries in li_temp
*                    where kunnr = li_temp-kunnr.
*                  if sy-subrc = 0.
*                    sort li_kna1 by kunnr.
*                  endif. " if sy-subrc = 0
*                  free : li_temp.
*                endif. " if li_temp is not initial
*
*                li_temp = li_proxy_in_item.
*                sort li_temp by konwa.
*                delete adjacent duplicates from li_temp comparing konwa.
*
*                if li_temp is not initial.
**Currency Key Validation
*                  select waers " Currency Key
*                  from   tcurc " Currency Codes
*                  into table li_tcurc
*                    for all entries in li_temp
*                    where waers = li_temp-konwa.
*                  if sy-subrc = 0.
*                    sort li_tcurc by waers.
*                  endif. " if sy-subrc = 0
*                  free li_temp.
*                endif. " if li_temp is not initial
*
*                if li_temp_mara is not initial.
*                  sort li_temp_mara by matnr.
*                  delete adjacent duplicates from li_temp_mara comparing matnr.
**Material number validation
*                  select  matnr " Material Number
*                    from mara   " General Material Data
*                  into table li_mara
*                  for all entries in li_temp_mara
*                  where   matnr =  li_temp_mara-matnr.
*
*                  if sy-subrc = 0.
*                    sort li_mara by matnr.
*                  endif. " if sy-subrc = 0
*                endif. " if li_temp_mara is not initial
*
*                loop at  li_proxy_in_item assigning <lfs_proxy_in_item>.
*
** Populate the Condition table
*                  clear lv_kotabnr.
*                  lv_kotabnr  = lc_005.
*                  lwa_bapicondct-table_no = lv_kotabnr.
*                  lwa_bapicondhd-table_no = lv_kotabnr.
*
**Populate the VARKEY
*                  concatenate     <lfs_proxy_in_item>-vkorg
*                                     <lfs_proxy_in_item>-vtweg
*                                     <lfs_proxy_in_item>-kunnr
*                                     into lwa_bapicondct-varkey.
*
*                  lwa_bapicondct-varkey+16 = <lfs_proxy_in_item>-matnr.
*
*                  lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
*                  clear lv_skip.
**Validate Condition type
*                  read table li_t685 with key kvewe = lwa_proxy_in_header-kvewe
*                                              kappl = lwa_proxy_in_header-kappl
*                                              kschl = lwa_proxy_in_header-kschl
*                                              transporting no fields
*                                              binary search.
*
*                  if sy-subrc is  not  initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_206.
*                    lwa_bapi_msg-message_v1 = lwa_proxy_in_header-kschl.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-matnr.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  endif. " if sy-subrc is not initial
*
*
**Validate Sales Org
*                  read table li_tvko with key vkorg = <lfs_proxy_in_item>-vkorg
*                                              transporting no fields
*                                              binary search.
*                  if sy-subrc is not initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_207.
*                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-vkorg.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-matnr.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  endif. " if sy-subrc is not initial
*
**Validate Dstribution channel
*                  read table li_tvtw with key vtweg = <lfs_proxy_in_item>-vtweg
*                                             transporting no fields
*                                             binary search.
*
*                  if sy-subrc is not initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_208.
*                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-vtweg.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-matnr.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  endif. " if sy-subrc is not initial
*
**Validate Customer Number
*                  read table li_kna1 assigning <lfs_kna1> with key kunnr = <lfs_proxy_in_item>-kunnr
*                                                                   binary search.
**If customer is not found
*                  if sy-subrc is not initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_209.
*                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-kunnr.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-matnr.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  else. " ELSE -> if sy-subrc is not initial
**If customer is found but blocked
*                    if <lfs_kna1>-aufsd is not initial.
*                      lv_commit_fail =  abap_true.
*                      lv_skip = abap_true.
*                      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                      lwa_bapi_msg-id         = attrc_msgid.
*                      lwa_bapi_msg-number     = lc_msg_210.
*                      lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-kunnr.
*                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                    endif. " if <lfs_kna1>-aufsd is not initial
*                  endif. " if sy-subrc is not initial
*
**Validate Currency Key
*                  read table li_tcurc with key waers = <lfs_proxy_in_item>-konwa
*                                                       transporting no fields
*                                                       binary search.
*                  if sy-subrc is not initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_211.
*                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-konwa.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-matnr.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  endif. " if sy-subrc is not initial
*
**Validate Material
*                  read table li_mara with key matnr = <lfs_proxy_in_item>-matnr
*                                              transporting no fields
*                                              binary search.
*                  if sy-subrc is not initial.
*                    lv_commit_fail =  abap_true.
*                    lv_skip = abap_true.
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg_212.
*                    lwa_bapi_msg-message_v1 = <lfs_proxy_in_item>-matnr.
*                    lwa_bapi_msg-message_v2 = <lfs_proxy_in_item>-vkorg.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                  endif. " if sy-subrc is not initial
*
**If there is no error in the data
*                  if lv_skip ne abap_true.
** If Condition records need to  insert
*                    if <lfs_proxy_in_item>-loevm_ko is initial.
*
*                      lwa_bapicondct-operation = lc_ins_op.
*                      lwa_bapicondct-cond_no = lc_cond_ins.
*                      lwa_bapicondhd-operation = lc_ins_op.
*                      lwa_bapicondhd-cond_no = lc_cond_ins.
*                      lwa_bapicondit-operation = lc_ins_op.
*                      lwa_bapicondit-cond_no = lc_cond_ins.
*                      lwa_bapicondit-cond_count = lc_kopos.
*                      lwa_bapicondhd-created_by = sy-uname.
*                      lwa_bapicondhd-creat_date = sy-datum.
*                      lwa_bapicondhd-valid_from = <lfs_proxy_in_item>-datab .
*                      lwa_bapicondhd-valid_to = <lfs_proxy_in_item>-datbi.
*                    endif. " if <lfs_proxy_in_item>-loevm_ko is initial
*
**Populate the tables to be passed in BAPI
*                    lwa_bapicondct-cond_usage = lwa_proxy_in_header-kvewe.
*                    lwa_bapicondct-applicatio = lwa_proxy_in_header-kappl.
*                    lwa_bapicondct-cond_type = lv_kschl .
*                    lwa_bapicondct-valid_to = <lfs_proxy_in_item>-datbi.
*                    lwa_bapicondct-valid_from = <lfs_proxy_in_item>-datab.
*                    lwa_bapicondhd-cond_usage = lwa_proxy_in_header-kvewe .
*                    lwa_bapicondhd-applicatio = lwa_proxy_in_header-kappl .
*                    lwa_bapicondhd-cond_type = lv_kschl.
*                    lwa_bapicondit-applicatio = lwa_proxy_in_header-kappl.
*                    lwa_bapicondit-cond_count = lc_kopos.
*                    lwa_bapicondit-cond_type = lv_kschl.
*                    lwa_bapicondit-cond_p_unt = <lfs_proxy_in_item>-kpein.
*                    lwa_bapicondit-cond_unit = <lfs_proxy_in_item>-kmein.
*                    lwa_bapicondit-calctypcon = lc_krech.
*                    lwa_bapicondit-cond_value = <lfs_proxy_in_item>-kbetr .
*                    lwa_bapicondit-condcurr = <lfs_proxy_in_item>-konwa.
*
*                    append  lwa_bapicondct to li_bapicondct.
*                    append lwa_bapicondhd to li_bapicondhd.
*                    append lwa_bapicondit to li_bapicondit.
*
*                    try.
** <--- Begin of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                        if <lfs_proxy_in_item>-loevm_ko is not initial.
** <--- End of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                          call function 'BAPI_PRICES_CONDITIONS'
*                            exporting
*                              pi_physical_deletion = lv_physically_del
*                            tables
*                              ti_bapicondct        = li_bapicondct
*                              ti_bapicondhd        = li_bapicondhd
*                              ti_bapicondit        = li_bapicondit
*                              ti_bapicondqs        = li_bapicondqs
*                              ti_bapicondvs        = li_bapicondvs
*                              to_bapiret2          = li_bapiret2
*                              to_bapiknumhs        = li_bapiknumhs
*                              to_mem_initial       = li_mem_initial
*                            exceptions
*                              update_error         = 1
*                              others               = 2.
** <--- Begin of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                        else. " ELSE -> if <lfs_proxy_in_item>-loevm_ko is not initial
*
*                          clear:lwa_price_data.
*                          refresh:li_konh,li_konp.
*                          create object lr_cond_utils.
*                          clear:lwa_price_data.
*                          lwa_price_data-vkorg = <lfs_proxy_in_item>-vkorg.
*                          lwa_price_data-vtweg = <lfs_proxy_in_item>-vtweg.
*                          lwa_price_data-datab = <lfs_proxy_in_item>-datab.
*                          lwa_price_data-datbi = <lfs_proxy_in_item>-datbi.
*                          lwa_price_data-kbetr = <lfs_proxy_in_item>-kbetr.
*                          lwa_price_data-kmein = <lfs_proxy_in_item>-kmein.
*                          lwa_price_data-konwa = <lfs_proxy_in_item>-konwa.
*                          lwa_price_data-kotabnr = lv_kotabnr.
*                          lwa_price_data-kpein = <lfs_proxy_in_item>-kpein.
*                          lwa_price_data-kschl = lv_kschl.
*                          lwa_price_data-matnr = <lfs_proxy_in_item>-matnr.
*
*** init maintenance session
*                          lwa_task-kvewe = lwa_proxy_in_header-kvewe.
*                          lwa_task-kappl = lwa_proxy_in_header-kappl.
*
**  Initialize condition maintenance
*                          try.
*                              call function 'COND_MNT_INIT'
*                                exporting
*                                  is_task      = lwa_task
*                                  iv_condtype  = lv_kschl
*                                  iv_condtable = lv_kotabnr
*                                  iv_activity  = lc_activity
*                                importing
*                                  ev_handle    = lv_handle
*                                  et_selection = li_selection.
*                            catch cx_cond_mnt_session.
*                              lwa_message-msgty = sy-msgty  .
*                              lwa_message-msgid = sy-msgid   .
*                              lwa_message-msgno = sy-msgno  .
*                              lwa_message-msgv1 = sy-msgv1 .
*                              lwa_message-msgv2 = sy-msgv2 .
*                              lwa_message-msgv3 = sy-msgv3 .
*                              lwa_message-msgv4 = sy-msgv4 .
*
*                              append lwa_message to li_messages.
*                              clear lwa_message.
*                          endtry.
*** Calculate temporary condition record number
*                          import lv_current_number1 to lv_current_number1 from memory id lv_temp_knumh_mem1.
*                          if sy-subrc = 4.
*                            lv_current_number1 = 0.
*                          endif. " if sy-subrc = 4
*                          lv_knumh(2) = lc_dolaar.
*                          lv_current_number1 = lv_current_number1 + 1.
*                          unpack lv_current_number1 to lv_knumh+2(8).
*                          if lv_temp_knumh_mem1 is initial.
*                            lv_modno = sy-modno.
*                            concatenate lc_temp_knumh lv_modno into lv_temp_knumh_mem1.
*                          endif. " if lv_temp_knumh_mem1 is initial
*                          export lv_current_number1 from lv_current_number1 to memory id lv_temp_knumh_mem1.
*
*                          lwa_konh-knumh = lv_knumh.
*                          lwa_konh-ernam = sy-uname.
*                          lwa_konh-erdat = sy-datlo.
*                          lwa_konh-kvewe = lwa_proxy_in_header-kvewe.
*                          lwa_konh-kotabnr = lv_kotabnr.
*                          lwa_konh-kappl = lc_kappl.
*                          lwa_konh-kschl = lv_kschl.
*                          lwa_konh-vakey = lwa_bapicondhd-varkey.
*                          lwa_konh-datab = lwa_price_data-datab.
*                          lwa_konh-datbi = lwa_price_data-datbi.
*                          append lwa_konh to li_konh.
*                          clear lwa_konh.
*
*                          lwa_konp-knumh = lv_knumh.
*                          lwa_konp-kopos = lc_kopos.
*                          lwa_konp-kbetr = lwa_price_data-kbetr.
*                          lwa_konp-kappl = lwa_proxy_in_header-kappl.
*                          lwa_konp-kschl = lv_kschl.
*                          lwa_konp-konwa = lwa_price_data-konwa.
*                          lwa_konp-kpein = lwa_price_data-kpein.
*                          lwa_konp-kmein = lwa_price_data-kmein.
*                          lwa_konp-kunnr = <lfs_proxy_in_item>-kunnr.
*                          append lwa_konp to li_konp.
*                          clear lwa_konp.
*
*                          lwa_record-kotabnr = lwa_price_data-kotabnr .
*                          lwa_record-kschl   = lwa_price_data-kschl   .
*                          lwa_record-datbi   = lwa_price_data-datbi  .
*                          lwa_record-datab   = lwa_price_data-datab   .
*
*                          try.
*                              call method lr_cond_utils->pack_datapart
*                                exporting
*                                  it_konh = li_konh
*                                  it_konp = li_konp
*                                receiving
*                                  result  = lwa_record-datapart.
*                            catch cx_cond_datacontainer .
*                              lwa_message-msgty = sy-msgty  .
*                              lwa_message-msgid = sy-msgid   .
*                              lwa_message-msgno = sy-msgno  .
*                              lwa_message-msgv1 = sy-msgv1 .
*                              lwa_message-msgv2 = sy-msgv2 .
*                              lwa_message-msgv3 = sy-msgv3 .
*                              lwa_message-msgv4 = sy-msgv4 .
*
*                              append lwa_message to li_messages.
*                              clear lwa_message.
*                          endtry.
*
*** start maintenance (create mode -> select records)
*                          try.
*                              call function 'COND_MNT_START'
*                                exporting
*                                  iv_handle      = lv_handle
*                                  iv_seldate     = sy-datum
*                                  iv_vakey       = lwa_bapicondhd-varkey
*                                importing
*                                  ev_subrc       = lv_subrc
*                                  et_messages    = li_messages
*                                  ev_recno       = lv_recno
*                                  et_record_keys = li_record_keys.
*                            catch cx_cond_mnt_session.
*                              lwa_message-msgty = sy-msgty  .
*                              lwa_message-msgid = sy-msgid   .
*                              lwa_message-msgno = sy-msgno  .
*                              lwa_message-msgv1 = sy-msgv1 .
*                              lwa_message-msgv2 = sy-msgv2 .
*                              lwa_message-msgv3 = sy-msgv3 .
*                              lwa_message-msgv4 = sy-msgv4 .
*
*                              append lwa_message to li_messages.
*                              clear lwa_message.
*                          endtry.
*
*                          append lines of li_messages to li_messages1.
*** Insert condition record
*                          lwa_record-kotabnr = lwa_price_data-kotabnr .
*                          lwa_record-kschl   = lwa_price_data-kschl   .
*                          lwa_record-datbi   = lwa_price_data-datbi  .
*                          lwa_record-datab   = lwa_price_data-datab   .
*                          lwa_record-vakey = lwa_bapicondhd-varkey.
*                          lwa_record-kvewe = lwa_proxy_in_header-kvewe.
*                          lwa_record-kappl = lwa_proxy_in_header-kappl.
*                          try.
*                              call function 'COND_MNT_RECORD_PUT'
*                                exporting
*                                  iv_handle        = lv_handle
*                                  iv_allow_overlap = abap_true
*                                  record_data      = lwa_record
*                                importing
*                                  ev_rec_id        = lwa_record_key-record_id
*                                  ev_subrc         = lv_subrc
*                                  et_messages      = li_messages.
*                            catch cx_cond_mnt_session.
*                              lwa_message-msgty = sy-msgty  .
*                              lwa_message-msgid = sy-msgid   .
*                              lwa_message-msgno = sy-msgno  .
*                              lwa_message-msgv1 = sy-msgv1 .
*                              lwa_message-msgv2 = sy-msgv2 .
*                              lwa_message-msgv3 = sy-msgv3 .
*                              lwa_message-msgv4 = sy-msgv4 .
*
*                              append lwa_message to li_messages1.
*                              clear lwa_message.
*                            catch cx_cond_mnt_record.
*                              lwa_message-msgty = sy-msgty  .
*                              lwa_message-msgid = sy-msgid   .
*                              lwa_message-msgno = sy-msgno  .
*                              lwa_message-msgv1 = sy-msgv1 .
*                              lwa_message-msgv2 = sy-msgv2 .
*                              lwa_message-msgv3 = sy-msgv3 .
*                              lwa_message-msgv4 = sy-msgv4 .
*
*
*                              append lwa_message to li_messages1.
*                              clear lwa_message.
*                          endtry.
*                          append lines of li_messages to li_messages1.
*                          if lv_subrc = 0.
*** Save condition record
*                            read table li_messages with key msgty = lc_error transporting no fields.
*                            if sy-subrc <> 0. " Check any errors occured
*                              read table li_messages with key msgty = lc_abort transporting no fields.
*                              if sy-subrc <> 0. " Check any abend message issued
*                                try.
*                                    call function 'COND_MNT_SAVE'
*                                      exporting
*                                        iv_handle      = lv_handle
*                                      importing
*                                        et_record_keys = li_record_keys
*                                        et_messages    = li_messages.
*                                  catch cx_cond_mnt_session.
*                                    lwa_message-msgty = sy-msgty  .
*                                    lwa_message-msgid = sy-msgid   .
*                                    lwa_message-msgno = sy-msgno  .
*                                    lwa_message-msgv1 = sy-msgv1 .
*                                    lwa_message-msgv2 = sy-msgv2 .
*                                    lwa_message-msgv3 = sy-msgv3 .
*                                    lwa_message-msgv4 = sy-msgv4 .
*
*
*                                    append lwa_message to li_messages.
*                                    clear lwa_message.
*                                endtry.
*                                wait up to 1 seconds.
*                                append lines of li_messages to li_messages1.
*                              endif. " if sy-subrc <> 0
*                            endif. " if sy-subrc <> 0
*                          else. " ELSE -> if lv_subrc = 0
*
*                          endif. " if lv_subrc = 0
*                          try.
*                              call function 'COND_MNT_END'
*                                exporting
*                                  iv_handle          = lv_handle
*                                  iv_ignore_dataloss = abap_true
*                                importing
*                                  et_messages        = li_messages.
*                            catch cx_cond_mnt_session.
*                          endtry.
*                          append lines of li_messages to li_messages1.
*
*                          loop at li_messages1 into lwa_message.
*                            lwa_bapiret2-type       = lwa_message-msgty.
*                            lwa_bapiret2-id         = lwa_message-msgid.
*                            lwa_bapiret2-number     = lwa_message-msgno.
*                            lwa_bapiret2-message_v1 = lwa_message-msgv1.
*                            lwa_bapiret2-message_v2 = lwa_message-msgv2.
*                            lwa_bapiret2-message_v2 = lwa_message-msgv2.
*                            lwa_bapiret2-message_v2 = lwa_message-msgv2.
*                            append lwa_bapiret2 to li_bapiret2.
*                            clear lwa_bapiret2.
*                          endloop. " loop at li_messages1 into lwa_message
*                        endif. " if <lfs_proxy_in_item>-loevm_ko is not initial
** <--- End of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                        if sy-subrc eq  0.
*                          read table li_bapiret2  with key  type  = lc_error transporting no fields . " Bapiret2 with ke of type
*                          if sy-subrc ne 0.
*                            read table li_bapiret2  with key  type  = lc_abort transporting  no fields . " Bapiret2 with ke of type
*                            if sy-subrc ne 0.
*                              if <lfs_proxy_in_item>-ztext is not initial   .
*
*                                read table  li_constants assigning <lfs_constants>
*                                                          with key criteria =    lc_text_procedure
*                                                                   active = abap_true.
*                                if sy-subrc is  initial.
*                                  read table li_bapiret2  assigning <lfs_bapiret2>  with key  type  = lc_success  . " Bapiret2 with ke of type
*                                  if sy-subrc eq 0.
** <--- Begin of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                                    if <lfs_proxy_in_item>-loevm_ko is not initial.
*                                      if <lfs_bapiret2>-message_v3  eq  lc_op_type .
*                                        concatenate <lfs_bapiret2>-message_v1 <lfs_constants>-sel_low into lv_fname.
*                                      endif. " if <lfs_bapiret2>-message_v3 eq lc_op_type
*                                    else. " ELSE -> if <lfs_proxy_in_item>-loevm_ko is not initial
*                                      read table li_record_keys assigning <lfs_record_key> index 1.
*                                      if sy-subrc eq 0.
*                                        concatenate <lfs_record_key>-knumh <lfs_constants>-sel_low into lwa_text_create-fname.
*                                        lwa_text_create-cond_value = <lfs_record_key>-knumh.
*                                      endif. " if sy-subrc eq 0
*                                      read table  li_constants assigning <lfs_constants>
*                                                                with key criteria =    lc_id
*                                                                         active = abap_true.
*                                      if sy-subrc is  initial.
*
*                                        lwa_text_create-tdid   = <lfs_constants>-sel_low .
*                                        lwa_text_create-tdline = <lfs_proxy_in_item>-ztext.
*                                        append  lwa_text_create to li_text_create .
*                                      endif. " if sy-subrc is initial
*                                    endif. " if <lfs_proxy_in_item>-loevm_ko is not initial
** <--- End of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*
** <--- Begin of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
**                                  ENDIF. " IF sy-subrc EQ 0
** <--- End of Insert for CR#D3_0047 & CR#D3_0048 by MTHATHA
*                                  endif. " if sy-subrc eq 0
*                                endif. " if sy-subrc is initial
*                              endif. " if <lfs_proxy_in_item>-ztext is not initial
*                            else. " ELSE -> if sy-subrc ne 0
*
*                              lv_commit_fail =  abap_true.
*
*                              loop at li_bapiret2 assigning <lfs_bapiret2>.
*                                if <lfs_bapiret2>-type eq lc_error  or
*                                   <lfs_bapiret2>-type eq lc_abort.
*                                  me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
*                                endif. " if <lfs_bapiret2>-type eq lc_error or
*                              endloop. " loop at li_bapiret2 assigning <lfs_bapiret2>
*                            endif. " if sy-subrc ne 0
*
*                          else. " ELSE -> if sy-subrc ne 0
*
*                            lv_commit_fail =  abap_true.
*
*                            loop at li_bapiret2 assigning <lfs_bapiret2>.
*                              if <lfs_bapiret2>-type eq lc_error or
*                                <lfs_bapiret2>-type eq lc_abort.
*                                me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
*                              endif. " if <lfs_bapiret2>-type eq lc_error or
*                            endloop. " loop at li_bapiret2 assigning <lfs_bapiret2>
*                          endif. " if sy-subrc ne 0
*                        endif. " if sy-subrc eq 0
*                      catch cx_root into lref_oref.
*                        lv_commit_fail =  abap_true.
*                        lv_text                 = lref_oref->get_text( ).
*                        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                        lwa_bapi_msg-id         = attrc_msgid.
*                        lwa_bapi_msg-number     = lc_msg.
*                        lwa_bapi_msg-message_v1 = lv_text.
*                        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*
*                    endtry.
*                  endif. " if lv_skip ne abap_true
*                  clear: lwa_bapicondct,
*                         lwa_bapicondhd ,
*                         lwa_bapicondit ,
*                         lwa_line.
*
*                  refresh: li_bapicondct,
*                           li_bapicondhd ,
*                           li_bapicondit,
*                           li_bapicondqs,
*                           li_bapicondvs,
*                           li_bapiret2,
*                           li_bapiknumhs,
*                           li_mem_initial.
*                endloop. " loop at li_proxy_in_item assigning <lfs_proxy_in_item>
***If the Input data is updated successsfully then the link between the message processing and the
**buisness document is created.
*                try .
*                    lv_protocol_name = lc_message.
*
***Class cl_proxy_access : To access ABAP proxy runtime objects without using a proxy instance
*                    call method cl_proxy_access=>get_server_context "Server Context
*                      receiving
*                        server_context = lref_server_cntxt.         "Server Context
*
***Method get_protocol :TO access the protocol class.
*                    call method lref_server_cntxt->get_protocol
*                      exporting
*                        protocol_name = lv_protocol_name "Protocol Name
*                      receiving
*                        protocol      = lref_protocol.   "Returns the Protocol Class
*
*                  catch cx_ai_system_fault into lref_oref.
*                    lv_commit_fail =  abap_true.
*                    lv_text                 = lref_oref->get_text( ).
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg.
*                    lwa_bapi_msg-message_v1 = lv_text.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                endtry.
*
***Get a protocol instance for the protocol IF_WSPROTOCOL_MESSAGE_ID.
*                try.
*                    lref_wsprotocol_msg_id ?= lref_protocol.
*                  catch cx_root into lref_oref.
*
*                    lv_commit_fail =  abap_true.
*                    lv_text                 = lref_oref->get_text( ).
*                    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*                    lwa_bapi_msg-id         = attrc_msgid.
*                    lwa_bapi_msg-number     = lc_msg.
*                    lwa_bapi_msg-message_v1 = lv_text.
*                    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                endtry.
** If any error occured previously for any record, no record will be updated. It can be update from FEH reprocess .
** If no error occued,  all record witll be created .
*                if   lv_commit_fail ne  abap_true    .
*
*                  call function 'BAPI_TRANSACTION_COMMIT'
*                    exporting
*                      wait = abap_true.
*
*                  loop at li_text_create  assigning <lfs_text_create> .
*
*                    lwa_line-tdline = <lfs_text_create>-tdline  .
*                    append  lwa_line to li_line .
*
** Create condition text  in condition
*                    call function 'CREATE_TEXT'
*                      exporting
*                        fid       = <lfs_text_create>-tdid
*                        flanguage = sy-langu
*                        fname     = <lfs_text_create>-fname
*                        fobject   = lc_object
*                      tables
*                        flines    = li_line
*                      exceptions
*                        no_init   = 1
*                        no_save   = 2
*                        others    = 3.
*                    if sy-subrc <> 0.
** Implement suitable error handling here
*                      lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
*                      lwa_bapi_msg-id         = attrc_msgid.
*                      lwa_bapi_msg-number     = lc_msg_199.
*                      lwa_bapi_msg-message_v1 = <lfs_text_create>-cond_value   .
*                      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                    endif. " if sy-subrc <> 0
*
**To have the system return the message ID after the sender has sent a request message
**or the receiver has received a request message, use the method GET_MESSAGE_ID of this instance.
**This returns the ID using the parameter MESSAGE_ID of the type SXMSGUID.
*                    if lref_cx_root is not bound.
*                      lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ). "XML-message ID determination
*                    endif. " if lref_cx_root is not bound
*
*
*                    if lv_xml_message_id is not initial.
*
***If the data is processed successfully but the file name is blank in Input data then the processing stops
*                      lwa_sxmspdata-msgguid    =  lv_xml_message_id. "PI Message ID
*                      lwa_sxmspdata-pid        =  lc_sender. "Default Value - Sender
*                      lwa_sxmspdata-name       =  lc_name. "Buisness Document ( B_DOCU )
***The reason 1 is directly passed and not as constant because in SLIN the warning is coming as
***Text literal '1' must be converted to the numeric literal 1
**It is more efficient to enter the numeric literal 1 directly,
*                      lwa_sxmspdata-extr_count =  1. "Default Value - 1
*                      read table li_bapiret2  assigning <lfs_bapiret2>  with key  type  = lc_success  . " Bapiret2 with ke of type
*                      if sy-subrc eq 0.
*                        lwa_sxmspdata-value      =  <lfs_bapiret2>-message_v1. "Value
*                      endif. " if sy-subrc eq 0
*                      lwa_sxmspdata-method     =  lc_success. "S
*                      append lwa_sxmspdata to li_sxmspdata.
*                      clear lwa_sxmspdata.
** <--- Begin of Insert for eztrac emi by MTHATHA
** Check EMI activated or not
*                      read table  li_constants
*                                  with key criteria =  lc_eztrac_ppm
*                                           sel_low  =  lwa_proxy_in_header-sender
*                                           active = abap_true
*                                           transporting no fields.
*                      if sy-subrc eq 0.
** <--- End of Insert for eztrac emi by MTHATHA
**FM ZDEV_UPDATE_SXMSPDATA: To link message processing with the buisness document created
**After the link is set up succesfully with this FM , the table SXMSPDATA is updated
**with the details.
*                        call function 'ZDEV_UPDATE_SXMSPDATA'
*                          exporting
*                            im_t_sxmspdata   = li_sxmspdata "Archive for Message Extract
*                          exceptions
*                            record_locked    = 1
*                            data_not_updated = 2
*                            others           = 3.
*
*                        if sy-subrc <> 0.
***Deallocate the Internal Table
*                          free li_sxmspdata.
***Add the warning message in the message container
*                          lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
*                          lwa_bapi_msg-id         = attrc_msgid.
*                          lwa_bapi_msg-number     = lc_msg_205.
*                          read table li_bapiret2  assigning <lfs_bapiret2>  with key  type  = lc_success  . " Bapiret2 with ke of type
*                          if sy-subrc eq 0.
*                            lwa_bapi_msg-message_v1     =  <lfs_bapiret2>-message_v1. "Value
*                          endif. " if sy-subrc eq 0
*
*                          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*                        endif. " if sy-subrc <> 0
** <--- Begin of Insert for eztrac emi by MTHATHA
*                      endif. " if sy-subrc eq 0
** <--- End of Insert for eztrac emi by MTHATHA
*                    endif. " if lv_xml_message_id is not initial
*                    clear: lwa_line,
*                           li_line,
*                           li_sxmspdata,
*                           lwa_sxmspdata.
*                  endloop. " loop at li_text_create assigning <lfs_text_create>
*                else. " ELSE -> if lv_commit_fail ne abap_true
*                  call function 'BAPI_TRANSACTION_ROLLBACK'.
*                endif. " if lv_commit_fail ne abap_true
*              endif. " if sy-subrc = 0
*            endif. " if sy-subrc = 0
*
*          endif. " if sy-subrc is initial
* <--- End of Insert for D3_Defect#9539 by MTHATHA
        endif. " if sy-subrc is initial
      endif. " if li_constants[] is not initial
    endif. " if lwa_proxy_in_header-sender is initial
* <--- End of Insert for D3_OTC_IDD_0042 by U024571
* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL
* Prepare FEH error
    if me->has_error( ) = abap_true.
      me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
      me->feh_prepare( im_input ).
    endif. " if me->has_error( ) = abap_true
* <--- End of Insert for D3_OTC_IDD_0203 by APAUL
  endmethod. "process_data
ENDCLASS.
