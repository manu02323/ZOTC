class ZOTCCL_PRICE_CONDITION_LOAD3 definition
  public
  final
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .   " Message container
  data GV_TMP_INPUT type Z01OTC_MT_TRANSFER_PRICE_LOAD .
  data GI_ENH_STATUS type ZDEV_TT_ENH_STATUS .

  methods CONSTRUCTOR .
  type-pools ABAP .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
  methods PROCESS_DATA
    importing
      !IM_INPUT type Z01OTC_DT_TRANSFER_PRICE_LOAD1 .   " Proxy Structure (generated)
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional   " Registration and Restarting of FEH
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION      " Registration and Restarting of FEH
    raising
      resumable(CX_SAPPLCO_STANDARD_MSG_FAULT)
      resumable(CX_MDG_BS_STD_MSG_FAULT) .
  methods FEH_PREPARE
    importing
      !IM_INPUT type Z01OTC_DT_TRANSFER_PRICE_LOAD1 .   " Proxy Structure (generated)
  PROTECTED SECTION.
private section.

  class-data ATTRV_ECH_ACTION type ref to ZOTCCL_PRICE_CONDITION_LOAD3 .     " Reference Interest Load
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG'. "#EC NOTEXT
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .   " Processing context of service implementation
  data GC_KSCHL_ZPPM type KSCHL value 'ZPPM'. "#EC NOTEXT . " .

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .   " Processing context of service implementation
ENDCLASS.



CLASS ZOTCCL_PRICE_CONDITION_LOAD3 IMPLEMENTATION.


  METHOD CONSTRUCTOR.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD3~CONSTRUCTOR               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042_DEFECT#9621                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*                                   DEFECT#9621                        *
*&---------------------------------------------------------------------*

    CREATE OBJECT attrv_msg_container.



  ENDMETHOD. "constructor


method feh_execute.
************************************************************************
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD3~FEH_EXECUTE               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042_DEFECT#9621                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*                                   DEFECT#9621                        *
*&---------------------------------------------------------------------*


  data: lv_raise_exception type xflag                       value is initial, "New Input Values
        lref_registration  type ref to cl_feh_registration  value is initial, "Registration and Restarting of FEH
        lref_cx_system     type ref to cx_ai_system_fault   value is initial, "Application Integration: Technical Error
        lv_mtext           type string                      value is initial, "Text value
        li_bapiret         type bapirettab                  value is initial. "Table with BAPI Return Information

  field-symbols  <lfs_feh_data> type zca_feh_data. "FEH Line

  constants      lc_msg_fault   type  classname value 'CX_SAPPLCO_STANDARD_MSG_FAULT'. " Reference type

  if lines( attrv_feh_data ) > 0.

    if im_ref_registration is bound.
      clear lv_raise_exception.
      lref_registration = im_ref_registration.
    else. " ELSE -> IF im_ref_registration IS BOUND
      lv_raise_exception = abap_true.
      lref_registration = cl_feh_registration=>s_initialize( is_single = space ).
    endif. " IF im_ref_registration IS BOUND

    try.
**Process all the FEH data
        loop at attrv_feh_data assigning <lfs_feh_data> .
          call method lref_registration->collect
            exporting
              i_external_guid  = <lfs_feh_data>-external_guid
              i_single_bo_ref  = <lfs_feh_data>-single_bo_ref
              i_hidden_data    = <lfs_feh_data>-hidden_data
              i_error_category = <lfs_feh_data>-error_category
              i_main_message   = <lfs_feh_data>-main_message
              i_messages       = <lfs_feh_data>-all_messages
              i_main_object    = <lfs_feh_data>-main_object
              i_objects        = <lfs_feh_data>-all_objects
              i_pre_mapping    = <lfs_feh_data>-pre_mapping.
          append lines of <lfs_feh_data>-all_messages to li_bapiret.
        endloop. " LOOP AT attrv_feh_data ASSIGNING <lfs_feh_data>
      catch cx_ai_system_fault into lref_cx_system.
        lv_mtext = lref_cx_system->get_text( ).
        message x026(bs_soa_common) with lv_mtext. "System error in the ForwardError Handling: &1
    endtry.

    free attrv_feh_data.

**Raise Exception

    if lv_raise_exception = abap_true.
 "Please raise the same exception in the proxy method definition
      call method cl_proxy_fault=>raise(
        exporting
          exception_class_name = lc_msg_fault
          bapireturn_tab       = li_bapiret ).

    endif. " IF lv_raise_exception = abap_true
  endif. " IF lines( attrv_feh_data ) > 0
endmethod. "feh_execute


  method feh_prepare.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD3~FEH_PREPARE               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042_DEFECT#9621                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*                                   DEFECT#9621                        *
*&---------------------------------------------------------------------*

    constants:lc_one              type ech_dte_objcat value '1',             "Object Category
              lc_ppm               type char3          value 'PPM',          " Gap of type CHAR3
              lc_obj_ppm           type char13         value 'OTC_IDD_0042'. " Obj_ppm of type CHAR13

    data:lwa_feh_data         type zca_feh_data                value is initial, "FEH Line
         lwa_ech_main_object  type ech_str_object              value is initial, "Object of Business Process
         li_applmsg           type applmsgtab                  value is initial, "Return Table for Messages
** Lr_data is used to in reference to proxy, so it can not be avoided
         lr_data              type ref to data                 value is initial, "Class
         lr_dref              type ref to data,                                  "  class
         lv_objkey            type ech_dte_objkey              value is initial, "Object Key
         lwa_bapiret          type bapiret2                    value is initial. "Return Parameter

    field-symbols: <lfs_appl_msg> type applmsg,                     "Return Structure for Messages
                   <lfs_input> type z01otc_dt_transfer_price_load1. " Proxy Structure (generated)

    concatenate lc_obj_ppm
                lc_ppm
                 into lv_objkey separated by space.

* The error category should depends on the actually error not below testing category
    lwa_feh_data-error_category  = attrv_msg_container->get_err_category( ).
    lwa_ech_main_object-objcat   = lc_one.
    lwa_ech_main_object-objtype  = me->attrv_objtype.
    lwa_ech_main_object-objkey   = lv_objkey.
    lwa_feh_data-main_object     = lwa_ech_main_object.

    create data lr_dref type z01otc_dt_transfer_price_load1. " Proxy Structure (generated)
    assign lr_dref->* to <lfs_input>.
    <lfs_input> = im_input.
    get reference of <lfs_input> into lr_data.
    if sy-subrc eq 0.
      lwa_feh_data-single_bo_ref = lr_data.
    endif. " if sy-subrc eq 0

    li_applmsg = attrv_msg_container->get_appl_messages( ).

    loop at li_applmsg assigning <lfs_appl_msg>.
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

      append lwa_bapiret to lwa_feh_data-all_messages.
      clear lwa_bapiret.
    endloop. " loop at li_applmsg assigning <lfs_appl_msg>

* Get main message from message container
    lwa_feh_data-main_message = attrv_msg_container->get_main_error( ).

* To Populate Main message
    read table lwa_feh_data-all_messages index 1 into lwa_feh_data-main_message.
    if sy-subrc ne 0.
      clear lwa_feh_data-main_message.
    endif. " if sy-subrc ne 0

    append lwa_feh_data to attrv_feh_data.
    clear lwa_feh_data.

  endmethod. "METH_INST_PUB_FEH_PREPARE


  METHOD HAS_ERROR.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD3~HAS_ERROR                 *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042_DEFECT#9621                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*                                   DEFECT#9621                        *
*&---------------------------------------------------------------------*

    re_result = attrv_msg_container->has_error( ).
  ENDMETHOD. "has_error


  METHOD IF_ECH_ACTION~FAIL.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                     *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
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
* PROGRAM    :  IF_ECH_ACTION~FINISH                                   *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
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
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                     *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*&---------------------------------------------------------------------*

**This method needs to be implemented to trigger the reprocessing of a message.
*The message will be called if Restart in Monitoring and Error Handling is
*clicked or if Repeat in Error  and  Conflict is selected

    DATA: lref_feh_registration  TYPE REF TO cl_feh_registration           VALUE IS INITIAL, "Registration and Restarting of FEH
*          lx_input               TYPE        Z01OTCMT_PRICE_CONDITION VALUE IS INITIAL. "Inbound Message type for IDD0203
          lx_input                TYPE     Z01OTC_DT_TRANSFER_PRICE_LOAD1 value is INITIAL ."Z01OTC_MT_TRANSFER_PRICE_LOAD VALUE IS INITIAL.

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
    me->process_data( im_input = lx_input ).

**If still, there is error
    IF me->has_error( ) = abap_true.
      me->feh_execute( im_ref_registration = lref_feh_registration ).
    ENDIF. " IF me->has_error( ) = abap_true

**Update the FEH
    lref_feh_registration->resolve_retry( ).
  ENDMETHOD. "if_ech_action~retry


  METHOD IF_ECH_ACTION~S_CREATE.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                     *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*&---------------------------------------------------------------------*
**This Generate Instance
    IF NOT attrv_ech_action IS BOUND.
      CREATE OBJECT attrv_ech_action.
    ENDIF. " IF NOT attrv_ech_action IS BOUND
    r_action_class = attrv_ech_action. "Class
  ENDMETHOD. "if_ech_action~s_create


  METHOD initialize.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                     *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*&---------------------------------------------------------------------*

    CONSTANTS : lc_retry    TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',   "Processing context of service implementation
                lc_fail     TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',    "Processing context of service implementation
                lc_finish   TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH',  "Processing context of service implementation
                lc_objtype  TYPE ech_dte_objtype             VALUE 'BUS2144', "Object Type
                lc_enh_name TYPE z_enhancement   VALUE 'OTC_IDD_0042'.        " Enhancement No.


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

    IF gi_enh_status[] IS INITIAL.
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_enh_name
        TABLES
          tt_enh_status     = gi_enh_status[].
      IF gi_enh_status[] IS NOT INITIAL.
        DELETE gi_enh_status WHERE active IS INITIAL.
      ENDIF. " IF gi_enh_status[] IS NOT INITIAL
    ENDIF. " IF gi_enh_status[] IS INITIAL

  ENDMETHOD. "INITIALIZE


  METHOD process_data.
************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD3~PROCESS_DATA              *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Deepanker Dwivedi                                      *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0042_DEFECT#9621                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042*
*                                   DEFECT#9621                        *
*&---------------------------------------------------------------------*
* 06-Apr-2017 ASK    E1DK926760  Defect # 2443 Amount conversion based *
*                                on currency                           *
*&---------------------------------------------------------------------*
* Constants
    CONSTANTS:
            lc_enh_name        TYPE z_enhancement   VALUE 'OTC_IDD_0042',             " Enhancement No.
            lc_kvewe           TYPE kvewe           VALUE 'A',                        " Usage of the condition table
            lc_eztrac_ppm      TYPE z_criteria      VALUE 'EZTRAC_PPM',               " Enh. Criteria
            lc_null            TYPE z_criteria      VALUE 'NULL',                     " Enh. Criteria
            lc_cond_val        TYPE z_criteria      VALUE 'CONDITION_VALUE',          " Enh. Criteria
            lc_005             TYPE kotabnr         VALUE '005'  ,                    " Condition table
            lc_ins_op          TYPE msgfn           VALUE '009',                      " Function
            lc_cond_ins        TYPE knumh           VALUE '$000000001',               " Condition record number
            lc_msg             TYPE symsgno         VALUE '000',                      "Message Number
            lc_msg_205         TYPE symsgno         VALUE '205',                      "Message Number
            lc_error           TYPE char1           VALUE 'E',                        "Error
            lc_message         TYPE char24          VALUE 'IF_WSPROTOCOL_MESSAGE_ID', "XI: Message ID
            lc_sender          TYPE sxmspid         VALUE 'SENDER',                   "Integration Engine: Pipeline ID
            lc_name            TYPE sxms_extr_name  VALUE 'B_DOCU',                   "Extractor Name
            lc_success         TYPE char1           VALUE 'S',                        "Success  message
            lc_abort           TYPE char1           VALUE 'A',                        "Abort  message
            lc_kopos           TYPE kopos           VALUE '01',                       " Sequential number of the condition
            lc_krech           TYPE krech           VALUE 'C',                        " Calculation type for condition
            lc_activity        TYPE cond_mnt_activity VALUE 'H',                      " Conditions: Maintenance Activity
            lc_dolaar          TYPE char2             VALUE '$$',                     " Dolaar of type CHAR2
            lc_temp_knumh      TYPE char10            VALUE 'TEMP_KNUMH',             " Temp_knumh of type CHAR10
            lc_kappl           TYPE kappl             VALUE 'V',                      " Application
            lc_msg_206         TYPE symsgno         VALUE '206',                      "Message Number
            lc_msg_207         TYPE symsgno         VALUE '207',                      "Message Number
            lc_msg_208         TYPE symsgno         VALUE '208',                      "Message Number
            lc_msg_209         TYPE symsgno         VALUE '209',                      "Message Number
            lc_msg_210         TYPE symsgno         VALUE '210',                      "Message Number
            lc_msg_211         TYPE symsgno         VALUE '211',                      "Message Number
            lc_msg_212         TYPE symsgno         VALUE '212'.                      "Message Number


    DATA:
         li_bapicondct          TYPE STANDARD TABLE OF bapicondct,      " BAPI struct. for condition tables (corresponds to COND_RECS)
         li_bapicondhd          TYPE STANDARD TABLE OF bapicondhd,      " BAPI Structure of KONH with English Field Names
         li_bapicondit          TYPE STANDARD TABLE OF bapicondit,      " BAPI Structure of KONP with English Field Names
         li_bapicondqs          TYPE STANDARD TABLE OF bapicondqs,      " BAPI Structure of KONM with English Field Names
         li_bapicondvs          TYPE STANDARD TABLE OF bapicondvs,      " BAPI Structure of KONW with English Field Names
         li_bapiret2            TYPE STANDARD TABLE OF bapiret2,        " Return Parameter
         li_bapiknumhs          TYPE STANDARD TABLE OF bapiknumhs,      " BAPI Structure for Assignment of KNUMHs
         li_mem_initial         TYPE STANDARD TABLE OF cnd_mem_initial, " Conditions: Buffer for Initial Upload
         lwa_bapicondct         TYPE bapicondct,                        " BAPI struct. for condition tables (corresponds to COND_RECS)
         lwa_bapicondhd         TYPE bapicondhd,                        " BAPI Structure of KONH with English Field Names
         lwa_bapicondit         TYPE bapicondit,                        " BAPI Structure of KONP with English Field Names
         lwa_bapiret2           TYPE bapiret2,                          " Return Parameter
         lv_kotabnr             TYPE kotabnr ,                          " Condition table
         lv_skip                TYPE char1,                             " Skip of type CHAR1
         lv_commit_fail         TYPE char1,                             " No commit
         lwa_line               TYPE  tline   ,                         " SAPscript: Text Lines
         lv_kschl               TYPE kschl,                             " Condition Type
         lv_matnr               TYPE matnr,                             " Material Number
         lv_vkorg               TYPE vkorg,                             " Sales Organization
         lv_vtweg               TYPE vtweg,                             " Distribution Channel
         lv_aufsd               TYPE aufsd,                             " Customer blocked for orders
         lv_waers               TYPE waers,                             " Currency Key
* FEH related  declaration
         lref_oref               TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
         lref_server_cntxt       TYPE REF TO if_ws_server_context         VALUE IS INITIAL, "Proxy Server Context
         lref_wsprotocol_msg_id  TYPE REF TO if_wsprotocol_message_id     VALUE IS INITIAL, "XI and WS: Read Message ID
         lref_protocol           TYPE REF TO if_wsprotocol                VALUE IS INITIAL, "ABAP Proxies: Available Protocols
         lref_cx_root            TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
         li_sxmspdata            TYPE STANDARD TABLE OF sxmspdata         INITIAL SIZE 0,   "Archive for Message Extract
         lwa_sxmspdata           TYPE sxmspdata                           VALUE IS INITIAL, "Archive for Message Extract
         lwa_bapi_msg            TYPE bapiret2                            VALUE IS INITIAL, "Return Parameter
         lv_protocol_name        TYPE string                              VALUE IS INITIAL, "Protocol Name
         lv_xml_message_id       TYPE sxmsmguid                           VALUE IS INITIAL, "XI: Message ID
         lv_text                 TYPE string                              VALUE IS INITIAL, "String
         li_konh                 TYPE TABLE OF  konh,                                       " Conditions (Header)
         li_konp                 TYPE TABLE OF konp,                                        " Conditions (Item)
         lwa_konh                TYPE konh,                                                 " Conditions (Header)
         lwa_konp                TYPE konp,                                                 " Conditions (Item)
         lwa_task                TYPE vkon_task_key,                                        " Admin. and Appl. (Task) of Condition Technique
         li_messages             TYPE cond_mnt_message_t,
         li_messages1            TYPE cond_mnt_message_t,
         lwa_message             TYPE cond_mnt_message,                                     " Condition Maintenance: Message Structure
         lv_subrc                TYPE cond_mnt_result,                                      " Result of Condition Maintenance
         lwa_price_data          TYPE price_details,                                        " Inbound proxy price details
         lv_handle               TYPE sytabix,                                              " Index of Internal Tables
         lwa_komg                TYPE komg,                                                 " Allowed Fields for Condition Structures
         li_selection            TYPE cl_cond_tab_sel=>cond_rngs_t,
         lv_vakey                TYPE vakey,                                                " Variable key 100 bytes
         lv_temp_knumh_mem1      TYPE char060,                                              " Knumh_mem1(60) of type Character
         lv_knumh                TYPE knumh VALUE '0000000000',                             " Condition record number
         lv_modno                TYPE char12,                                               " Modno(12) of type Character
         lwa_record              TYPE cond_mnt_record_data,                                 " Condition Maintenance: Condition Record (Key and Data)
         lv_recno                TYPE syloopc,                                              " Visible Lines of a Step Loop
         lv_idx                  TYPE sytabix,                                              " Index of Internal Tables
         li_record_keys          TYPE cond_mnt_record_key_t,
         lwa_record_key          TYPE cond_mnt_record_key,                                  " Condition Maintenance: ID and Key of a Condition Record
         lwa_selection           TYPE LINE OF cl_cond_tab_sel=>cond_rngs_t,
         lr_cond_utils           TYPE REF TO cl_cond_mnt_util_a,                            " Utilities for Price Maintenance
         lv_current_number1      TYPE char04,                                               " Current_number1(4) of type Character
         li_con_005_zm01         TYPE STANDARD TABLE OF lty_con_005,                        " Condition Table
         lv_kbetr                TYPE kbetr_kond,                                           " Defect # 2443
         lv_bapicurr_d           TYPE bapicurr_d,                                           " Defect # 2443
         lwa_item       TYPE z01otc_dt_transfer_price_load1.                                " Proxy Structure (generated)

    DATA : lv_date_tmp(10) TYPE c ,                           " Date_tmp(10) of type Character
           lv_from_date(8) TYPE c,                            " From_date(8) of type Character
           lv_to_date(8) TYPE c,                              " To_date(8) of type Character
           lv_dd(2) TYPE c,                                   " Dd(2) of type Character
           lv_mm(2) TYPE c,                                   " Yy(2) of type Character
           lv_yyyy(4) TYPE c,                                 " Yyyy(4) of type Character
           lv_tmp_input  TYPE z01otc_mt_transfer_price_load . " Proxy Structure (generated)

* Field Symbols
    FIELD-SYMBOLS  :
           <lfs_enh_status>         TYPE zdev_enh_status                 , " Enhancement Status
           <lfs_bapiret2>          TYPE bapiret2 ,                         " Return Parameter
           <lfs_kna1>              TYPE lty_kna1.

    TRY.
**Initialize FEH message container
        me->initialize( ).
      CATCH cx_root INTO lref_oref.
        lv_text                 = lref_oref->get_text( ).
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg.
        lwa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDTRY.

* Pass on the message data to local variable
    lwa_item = im_input.

*  Clear li_temp_mara.
    IF lwa_item-kunnr  IS  NOT INITIAL .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lwa_item-kunnr
        IMPORTING
          output = lwa_item-kunnr.
    ENDIF. " IF lwa_item-kunnr IS NOT INITIAL

*  Convert from and to date .
    lv_date_tmp = lwa_item-valid_from .
    SPLIT   lv_date_tmp AT '.' INTO lv_dd lv_mm lv_yyyy .
    IF lv_yyyy IS NOT INITIAL AND lv_dd IS NOT INITIAL AND lv_mm IS NOT INITIAL .
      CONCATENATE lv_yyyy lv_mm lv_dd INTO lv_from_date.
      lwa_item-valid_from = lv_from_date .
    ENDIF. " IF lv_yyyy IS NOT INITIAL AND lv_dd IS NOT INITIAL AND lv_mm IS NOT INITIAL
    CLEAR: lv_date_tmp, lv_dd ,lv_mm, lv_yyyy, lv_from_date .

    lv_date_tmp = lwa_item-valid_to .
    SPLIT   lv_date_tmp AT '.' INTO lv_dd lv_mm lv_yyyy .
    IF lv_yyyy IS NOT INITIAL AND lv_dd IS NOT INITIAL AND lv_mm IS NOT INITIAL .
      CONCATENATE lv_yyyy lv_mm lv_dd INTO lv_to_date.
      lwa_item-valid_to = lv_to_date .
    ENDIF. " IF lv_yyyy IS NOT INITIAL AND lv_dd IS NOT INITIAL AND lv_mm IS NOT INITIAL
    CLEAR: lv_date_tmp, lv_dd ,lv_mm, lv_yyyy , lv_to_date.


* Populate the Condition table
    CLEAR lv_kotabnr.
    READ TABLE gi_enh_status
    WITH KEY criteria = lc_cond_val
    ASSIGNING <lfs_enh_status> .
    IF sy-subrc EQ 0.
      lv_kotabnr  = <lfs_enh_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    lwa_bapicondct-table_no = lv_kotabnr.
    lwa_bapicondhd-table_no = lv_kotabnr.

*Populate the VARKEY
    CONCATENATE     lwa_item-vkorg
                    lwa_item-vtweg
                    lwa_item-kunnr
               INTO lwa_bapicondct-varkey.

    lwa_bapicondct-varkey+16 = lwa_item-matnr.

    lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
    CLEAR lv_skip.
* Validate Condition type
    SELECT SINGLE kschl INTO lv_kschl
    FROM   t685 " Conditions: Types
      WHERE kvewe =  lc_kvewe
      AND   kappl =  lc_kappl
      AND   kschl =  lwa_item-kschl.
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_206.
      lwa_bapi_msg-message_v1 = gc_kschl_zppm.
      lwa_bapi_msg-message_v2 = lwa_item-matnr.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL


* Validate Sales Org
    SELECT SINGLE vkorg INTO lv_vkorg
      FROM tvko " Organizational Unit: Sales Organizations
    WHERE vkorg = lwa_item-vkorg.
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_207.
      lwa_bapi_msg-message_v1 = lwa_item-vkorg.
      lwa_bapi_msg-message_v2 = lwa_item-matnr.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL

* Validate Dstribution channel
    SELECT SINGLE vtweg INTO lv_vtweg
      FROM tvtw " Organizational Unit: Distribution Channels
    WHERE vtweg = lwa_item-vtweg.
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_208.
      lwa_bapi_msg-message_v1 = lwa_item-vtweg.
      lwa_bapi_msg-message_v2 = lwa_item-matnr.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL

* Validate Customer Number
    SELECT SINGLE aufsd INTO lv_aufsd
      FROM kna1 " General Data in Customer Master
    WHERE kunnr = lwa_item-kunnr.
*If customer is not found
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_209.
      lwa_bapi_msg-message_v1 = lwa_item-kunnr.
      lwa_bapi_msg-message_v2 = lwa_item-matnr.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
*If customer is found but blocked
      IF lv_aufsd IS NOT INITIAL.
        lv_commit_fail =  abap_true.
        lv_skip = abap_true.
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg_210.
        lwa_bapi_msg-message_v1 = lwa_item-kunnr.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      ENDIF. " IF lv_aufsd IS NOT INITIAL
    ENDIF. " IF sy-subrc IS NOT INITIAL

* Validate Currency Key
    SELECT SINGLE waers INTO lv_waers
       FROM tcurc " Currency Codes
    WHERE waers = lwa_item-waers.
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_211.
      lwa_bapi_msg-message_v1 = lwa_item-waers.
      lwa_bapi_msg-message_v2 = lwa_item-matnr.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL

* Validate Material
    SELECT SINGLE matnr INTO lv_matnr
       FROM mara " General Material Data
    WHERE matnr = lwa_item-matnr.
    IF sy-subrc IS NOT INITIAL.
      lv_commit_fail =  abap_true.
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_212.
      lwa_bapi_msg-message_v1 = lwa_item-matnr.
      lwa_bapi_msg-message_v2 = lwa_item-vkorg.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL

*If there is no error in the data
    IF lv_skip NE abap_true.
* If Condition records need to  insert
      lwa_bapicondct-operation = lc_ins_op.
      lwa_bapicondct-cond_no = lc_cond_ins.
      lwa_bapicondhd-operation = lc_ins_op.
      lwa_bapicondhd-cond_no = lc_cond_ins.
      lwa_bapicondit-operation = lc_ins_op.
      lwa_bapicondit-cond_no = lc_cond_ins.
      lwa_bapicondit-cond_count = lc_kopos.
      lwa_bapicondhd-created_by = sy-uname.
      lwa_bapicondhd-creat_date = sy-datum.
      lwa_bapicondhd-valid_from = lwa_item-valid_from.
      lwa_bapicondhd-valid_to = lwa_item-valid_to.

*Populate the tables to be passed in BAPI
      lwa_bapicondct-cond_usage = lc_kvewe .
      lwa_bapicondct-applicatio = lc_kappl .
      lwa_bapicondct-cond_type = gc_kschl_zppm .
      lwa_bapicondct-valid_to = lwa_item-valid_to.
      lwa_bapicondct-valid_from = lwa_item-valid_from.
      lwa_bapicondhd-cond_usage = lc_kvewe .
      lwa_bapicondhd-applicatio = lc_kappl .
      lwa_bapicondhd-cond_type =  gc_kschl_zppm.
      lwa_bapicondit-applicatio = lc_kvewe .
      lwa_bapicondit-cond_count = lc_kopos.
      lwa_bapicondit-cond_type =  gc_kschl_zppm.
      lwa_bapicondit-cond_p_unt = lwa_item-pro.
      lwa_bapicondit-cond_unit = lwa_item-me .
      lwa_bapicondit-calctypcon = lc_krech.
      lwa_bapicondit-cond_value = lwa_item-kbetr .
      lwa_bapicondit-condcurr = lwa_item-waers.

      APPEND  lwa_bapicondct TO li_bapicondct.
      APPEND lwa_bapicondhd TO li_bapicondhd.
      APPEND lwa_bapicondit TO li_bapicondit.

      TRY.
          CLEAR:lwa_price_data.
          CLEAR :li_konh[],li_konp[].
          CREATE OBJECT lr_cond_utils.
          CLEAR:lwa_price_data.

* Begin of Change for Defect 2443 by ASK
          CLEAR:  lv_kbetr,lv_bapicurr_d.
          lv_bapicurr_d =  lwa_item-kbetr.
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
            EXPORTING
              currency             = lwa_item-waers
              amount_external      = lv_bapicurr_d
              max_number_of_digits = '23'
            IMPORTING
              amount_internal      = lv_kbetr.
* End   of Change for Defect 2443 by ASK


          lwa_price_data-vkorg = lwa_item-vkorg.
          lwa_price_data-vtweg = lwa_item-vtweg.
          lwa_price_data-datab = lwa_item-valid_from.
          lwa_price_data-datbi = lwa_item-valid_to.

*          lwa_price_data-kbetr = lwa_item-kbetr.    " Defect 2443 by ASK
          lwa_price_data-kbetr = lv_kbetr. " Defect 2443 by ASK

          lwa_price_data-kmein = lwa_item-me.
          lwa_price_data-konwa = lwa_item-waers.
          lwa_price_data-kotabnr = lv_kotabnr.
          lwa_price_data-kpein = lwa_item-pro.
          lwa_price_data-kschl = gc_kschl_zppm.
          lwa_price_data-matnr = lwa_item-matnr.

** init maintenance session
          lwa_task-kvewe = lc_kvewe .
          lwa_task-kappl = lc_kappl .

*  Initialize condition maintenance
          TRY.
              CALL FUNCTION 'COND_MNT_INIT'
                EXPORTING
                  is_task      = lwa_task
                  iv_condtype  = gc_kschl_zppm
                  iv_condtable = lv_kotabnr
                  iv_activity  = lc_activity
                IMPORTING
                  ev_handle    = lv_handle
                  et_selection = li_selection.
            CATCH cx_cond_mnt_session.
              lwa_message-msgty = sy-msgty  .
              lwa_message-msgid = sy-msgid   .
              lwa_message-msgno = sy-msgno  .
              lwa_message-msgv1 = sy-msgv1 .
              lwa_message-msgv2 = sy-msgv2 .
              lwa_message-msgv3 = sy-msgv3 .
              lwa_message-msgv4 = sy-msgv4 .

              APPEND lwa_message TO li_messages.
              CLEAR lwa_message.
          ENDTRY.
** Calculate temporary condition record number
          IMPORT lv_current_number1 TO lv_current_number1 FROM MEMORY ID lv_temp_knumh_mem1.
          IF sy-subrc = 4.
            lv_current_number1 = 0.
          ENDIF. " IF sy-subrc = 4
          lv_knumh(2) = lc_dolaar.
          lv_current_number1 = lv_current_number1 + 1.
          UNPACK lv_current_number1 TO lv_knumh+2(8).
          IF lv_temp_knumh_mem1 IS INITIAL.
            lv_modno = sy-modno.
            CONCATENATE lc_temp_knumh lv_modno INTO lv_temp_knumh_mem1.
          ENDIF. " IF lv_temp_knumh_mem1 IS INITIAL
          EXPORT lv_current_number1 FROM lv_current_number1 TO MEMORY ID lv_temp_knumh_mem1.

          lwa_konh-knumh = lv_knumh.
          lwa_konh-ernam = sy-uname.
          lwa_konh-erdat = sy-datlo.
          lwa_konh-kvewe = lc_kvewe .
          lwa_konh-kotabnr = lv_kotabnr.
          lwa_konh-kappl = lc_kappl.
          lwa_konh-kschl = gc_kschl_zppm.
          lwa_konh-vakey = lwa_bapicondhd-varkey.
          lwa_konh-datab = lwa_price_data-datab.
          lwa_konh-datbi = lwa_price_data-datbi.
          APPEND lwa_konh TO li_konh.
          CLEAR lwa_konh.

          lwa_konp-knumh = lv_knumh.
          lwa_konp-kopos = lc_kopos.
          lwa_konp-kbetr = lwa_price_data-kbetr.
          lwa_konp-kappl = lc_kappl .
          lwa_konp-kschl = gc_kschl_zppm.
          lwa_konp-konwa = lwa_price_data-konwa.
          lwa_konp-kpein = lwa_price_data-kpein.
          lwa_konp-kmein = lwa_price_data-kmein.
          lwa_konp-kunnr = lwa_item-kunnr.
          APPEND lwa_konp TO li_konp.
          CLEAR lwa_konp.

          lwa_record-kotabnr = lwa_price_data-kotabnr .
          lwa_record-kschl   = lwa_price_data-kschl   .
          lwa_record-datbi   = lwa_price_data-datbi  .
          lwa_record-datab   = lwa_price_data-datab   .

          TRY.
              CALL METHOD lr_cond_utils->pack_datapart
                EXPORTING
                  it_konh = li_konh
                  it_konp = li_konp
                RECEIVING
                  result  = lwa_record-datapart.
            CATCH cx_cond_datacontainer .
              lwa_message-msgty = sy-msgty  .
              lwa_message-msgid = sy-msgid   .
              lwa_message-msgno = sy-msgno  .
              lwa_message-msgv1 = sy-msgv1 .
              lwa_message-msgv2 = sy-msgv2 .
              lwa_message-msgv3 = sy-msgv3 .
              lwa_message-msgv4 = sy-msgv4 .

              APPEND lwa_message TO li_messages.
              CLEAR lwa_message.
          ENDTRY.

** start maintenance (create mode -> select records)
          TRY.
              CALL FUNCTION 'COND_MNT_START'
                EXPORTING
                  iv_handle      = lv_handle
                  iv_seldate     = sy-datum
                  iv_vakey       = lwa_bapicondhd-varkey
                IMPORTING
                  ev_subrc       = lv_subrc
                  et_messages    = li_messages
                  ev_recno       = lv_recno
                  et_record_keys = li_record_keys.
            CATCH cx_cond_mnt_session.
              lwa_message-msgty = sy-msgty  .
              lwa_message-msgid = sy-msgid   .
              lwa_message-msgno = sy-msgno  .
              lwa_message-msgv1 = sy-msgv1 .
              lwa_message-msgv2 = sy-msgv2 .
              lwa_message-msgv3 = sy-msgv3 .
              lwa_message-msgv4 = sy-msgv4 .

              APPEND lwa_message TO li_messages.
              CLEAR lwa_message.
          ENDTRY.

          APPEND LINES OF li_messages TO li_messages1.
** Insert condition record
          lwa_record-kotabnr = lwa_price_data-kotabnr .
          lwa_record-kschl   = lwa_price_data-kschl   .
          lwa_record-datbi   = lwa_price_data-datbi  .
          lwa_record-datab   = lwa_price_data-datab   .
          lwa_record-vakey = lwa_bapicondhd-varkey.
          lwa_record-kvewe = lc_kvewe .
          lwa_record-kappl = lc_kappl .
          TRY.
              CALL FUNCTION 'COND_MNT_RECORD_PUT'
                EXPORTING
                  iv_handle        = lv_handle
                  iv_allow_overlap = abap_true
                  record_data      = lwa_record
                IMPORTING
                  ev_rec_id        = lwa_record_key-record_id
                  ev_subrc         = lv_subrc
                  et_messages      = li_messages.
            CATCH cx_cond_mnt_session.
              lwa_message-msgty = sy-msgty  .
              lwa_message-msgid = sy-msgid   .
              lwa_message-msgno = sy-msgno  .
              lwa_message-msgv1 = sy-msgv1 .
              lwa_message-msgv2 = sy-msgv2 .
              lwa_message-msgv3 = sy-msgv3 .
              lwa_message-msgv4 = sy-msgv4 .

              APPEND lwa_message TO li_messages1.
              CLEAR lwa_message.
            CATCH cx_cond_mnt_record.
              lwa_message-msgty = sy-msgty  .
              lwa_message-msgid = sy-msgid   .
              lwa_message-msgno = sy-msgno  .
              lwa_message-msgv1 = sy-msgv1 .
              lwa_message-msgv2 = sy-msgv2 .
              lwa_message-msgv3 = sy-msgv3 .
              lwa_message-msgv4 = sy-msgv4 .


              APPEND lwa_message TO li_messages1.
              CLEAR lwa_message.
          ENDTRY.
          APPEND LINES OF li_messages TO li_messages1.
          IF lv_subrc = 0.
** Save condition record
            READ TABLE li_messages WITH KEY msgty = lc_error TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0. " Check any errors occured
              READ TABLE li_messages WITH KEY msgty = lc_abort TRANSPORTING NO FIELDS.
              IF sy-subrc <> 0. " Check any abend message issued
                TRY.
                    CALL FUNCTION 'COND_MNT_SAVE'
                      EXPORTING
                        iv_handle      = lv_handle
                      IMPORTING
                        et_record_keys = li_record_keys
                        et_messages    = li_messages.
                  CATCH cx_cond_mnt_session.
                    lwa_message-msgty = sy-msgty  .
                    lwa_message-msgid = sy-msgid   .
                    lwa_message-msgno = sy-msgno  .
                    lwa_message-msgv1 = sy-msgv1 .
                    lwa_message-msgv2 = sy-msgv2 .
                    lwa_message-msgv3 = sy-msgv3 .
                    lwa_message-msgv4 = sy-msgv4 .


                    APPEND lwa_message TO li_messages.
                    CLEAR lwa_message.
                ENDTRY.
                WAIT UP TO 1 SECONDS.
                APPEND LINES OF li_messages TO li_messages1.
              ENDIF. " IF sy-subrc <> 0
            ENDIF. " IF sy-subrc <> 0
          ELSE. " ELSE -> IF lv_subrc = 0

          ENDIF. " IF lv_subrc = 0
          TRY.
              CALL FUNCTION 'COND_MNT_END'
                EXPORTING
                  iv_handle          = lv_handle
                  iv_ignore_dataloss = abap_true
                IMPORTING
                  et_messages        = li_messages.
            CATCH cx_cond_mnt_session.
          ENDTRY.
          APPEND LINES OF li_messages TO li_messages1.

          LOOP AT li_messages1 INTO lwa_message.
            lwa_bapiret2-type       = lwa_message-msgty.
            lwa_bapiret2-id         = lwa_message-msgid.
            lwa_bapiret2-number     = lwa_message-msgno.
            lwa_bapiret2-message_v1 = lwa_message-msgv1.
            lwa_bapiret2-message_v2 = lwa_message-msgv2.
            lwa_bapiret2-message_v2 = lwa_message-msgv2.
            lwa_bapiret2-message_v2 = lwa_message-msgv2.
            APPEND lwa_bapiret2 TO li_bapiret2.
            CLEAR lwa_bapiret2.
          ENDLOOP. " LOOP AT li_messages1 INTO lwa_message
          IF sy-subrc EQ  0.
            READ TABLE li_bapiret2  WITH KEY  type  = lc_error TRANSPORTING NO FIELDS . " Bapiret2 with ke of type
            IF sy-subrc NE 0.
              READ TABLE li_bapiret2  WITH KEY  type  = lc_abort TRANSPORTING  NO FIELDS . " Bapiret2 with ke of type
              IF sy-subrc NE 0.
                READ TABLE li_bapiret2  ASSIGNING <lfs_bapiret2>  WITH KEY  type  = lc_success  . " Bapiret2 with ke of type

                IF sy-subrc EQ 0.

                ELSE. " ELSE -> IF sy-subrc EQ 0
                  lv_commit_fail =  abap_true.

                  LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>.
                    IF <lfs_bapiret2>-type EQ lc_error OR
                      <lfs_bapiret2>-type EQ lc_abort.
                      me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                    ENDIF. " IF <lfs_bapiret2>-type EQ lc_error OR
                  ENDLOOP. " LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>
                ENDIF. " IF sy-subrc EQ 0
              ELSE. " ELSE -> IF sy-subrc NE 0
                lv_commit_fail =  abap_true.
                LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>.
                  IF <lfs_bapiret2>-type EQ lc_error  OR
                     <lfs_bapiret2>-type EQ lc_abort.
                    me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                  ENDIF. " IF <lfs_bapiret2>-type EQ lc_error OR
                ENDLOOP. " LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>
              ENDIF. " IF sy-subrc NE 0
            ELSE. " ELSE -> IF sy-subrc NE 0
              lv_commit_fail =  abap_true.
              LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>.
                IF <lfs_bapiret2>-type EQ lc_error OR
                  <lfs_bapiret2>-type EQ lc_abort.
                  me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                ENDIF. " IF <lfs_bapiret2>-type EQ lc_error OR
              ENDLOOP. " LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF sy-subrc EQ 0
        CATCH cx_root INTO lref_oref.
          lv_commit_fail =  abap_true.
          lv_text                 = lref_oref->get_text( ).
          lwa_bapi_msg-type       = zcacl_message_container=>c_error.
          lwa_bapi_msg-id         = attrc_msgid.
          lwa_bapi_msg-number     = lc_msg.
          lwa_bapi_msg-message_v1 = lv_text.
          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

      ENDTRY.
    ENDIF. " IF lv_skip NE abap_true
    CLEAR: lwa_bapicondct,
           lwa_bapicondhd ,
           lwa_bapicondit ,
           lwa_line.

    CLEAR  : li_bapicondct[],
             li_bapicondhd[] ,
             li_bapicondit[],
             li_bapicondqs[],
             li_bapicondvs[],
             li_bapiret2[],
             li_bapiknumhs[],
             li_mem_initial[],
             li_messages1[].
**If the Input data is updated successsfully then the link between the message processing and the
*buisness document is created.
    TRY .
        lv_protocol_name = lc_message.

**Class cl_proxy_access : To access ABAP proxy runtime objects without using a proxy instance
        CALL METHOD cl_proxy_access=>get_server_context "Server Context
          RECEIVING
            server_context = lref_server_cntxt.         "Server Context

**Method get_protocol :TO access the protocol class.
        CALL METHOD lref_server_cntxt->get_protocol
          EXPORTING
            protocol_name = lv_protocol_name "Protocol Name
          RECEIVING
            protocol      = lref_protocol.   "Returns the Protocol Class

      CATCH cx_ai_system_fault INTO lref_oref.
        lv_commit_fail =  abap_true.
        lv_text                 = lref_oref->get_text( ).
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg.
        lwa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDTRY.

**Get a protocol instance for the protocol IF_WSPROTOCOL_MESSAGE_ID.
    TRY.
        lref_wsprotocol_msg_id ?= lref_protocol.
      CATCH cx_root INTO lref_oref.

        lv_commit_fail =  abap_true.
        lv_text                 = lref_oref->get_text( ).
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg.
        lwa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDTRY.
* If any error occured previously for any record, no record will be updated. It can be update from FEH reprocess .
* If no error occued,  all record witll be created .
    IF   lv_commit_fail NE  abap_true    .

      CALL METHOD cl_soap_commit_rollback=>commit.

*  *To have the system return the message ID after the sender has sent a request message
*or the receiver has received a request message, use the method GET_MESSAGE_ID of this instance.
*This returns the ID using the parameter MESSAGE_ID of the type SXMSGUID.
      IF lref_cx_root IS NOT BOUND.
        lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ). "XML-message ID determination
      ENDIF. " IF lref_cx_root IS NOT BOUND

      IF lv_xml_message_id IS NOT INITIAL.

**If the data is processed successfully but the file name is blank in Input data then the processing stops
        lwa_sxmspdata-msgguid    =  lv_xml_message_id. "PI Message ID
        lwa_sxmspdata-pid        =  lc_sender. "Default Value - Sender
        lwa_sxmspdata-name       =  lc_name. "Buisness Document ( B_DOCU )
**The reason 1 is directly passed and not as constant because in SLIN the warning is coming as
**Text literal '1' must be converted to the numeric literal 1
*It is more efficient to enter the numeric literal 1 directly,
        lwa_sxmspdata-extr_count =  1. "Default Value - 1
        READ TABLE li_bapiret2  ASSIGNING <lfs_bapiret2>  WITH KEY  type  = lc_success  . " Bapiret2 with ke of type
        IF sy-subrc EQ 0.
          lwa_sxmspdata-value      =  <lfs_bapiret2>-message_v1. "Value
        ENDIF. " IF sy-subrc EQ 0
        lwa_sxmspdata-method     =  lc_success. "S
        APPEND lwa_sxmspdata TO li_sxmspdata.
        CLEAR lwa_sxmspdata.
* Check EMI activated or not*
        READ TABLE  gi_enh_status
                    WITH KEY criteria =  lc_eztrac_ppm
                             sel_low  =  'PPM' "lwa_proxy_in_header-sender
                             active = abap_true
                             TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
*FM ZDEV_UPDATE_SXMSPDATA: To link message processing with the buisness document created
*After the link is set up succesfully with this FM , the table SXMSPDATA is updated
*with the details.
          CALL FUNCTION 'ZDEV_UPDATE_SXMSPDATA'
            EXPORTING
              im_t_sxmspdata   = li_sxmspdata "Archive for Message Extract
            EXCEPTIONS
              record_locked    = 1
              data_not_updated = 2
              OTHERS           = 3.

          IF sy-subrc <> 0.
**Deallocate the Internal Table
            FREE li_sxmspdata.
**Add the warning message in the message container
            lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
            lwa_bapi_msg-id         = attrc_msgid.
            lwa_bapi_msg-number     = lc_msg_205.
            READ TABLE li_bapiret2  ASSIGNING <lfs_bapiret2>  WITH KEY  type  = lc_success  . " Bapiret2 with ke of type
            IF sy-subrc EQ 0.
              lwa_bapi_msg-message_v1     =  <lfs_bapiret2>-message_v1. "Value
            ENDIF. " IF sy-subrc EQ 0

            me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_xml_message_id IS NOT INITIAL
      CLEAR: lwa_line,
             li_sxmspdata,
             lwa_sxmspdata.
    ELSE. " ELSE -> IF lv_commit_fail NE abap_true
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CALL METHOD cl_soap_commit_rollback=>rollback( ).
    ENDIF. " IF lv_commit_fail NE abap_true
* Prepare FEH error
    IF me->has_error( ) = abap_true.
      me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
      me->feh_prepare( im_input ).
    ENDIF. " IF me->has_error( ) = abap_true

  ENDMETHOD. "process_data
ENDCLASS.
