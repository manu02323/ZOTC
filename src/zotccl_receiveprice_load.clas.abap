class ZOTCCL_RECEIVEPRICE_LOAD definition
  public
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .
  data GV_TMP_INPUT type Z01OTC_MT_RECEIVE_PRICE .
  data GI_ENH_STATUS type ZDEV_TT_ENH_STATUS .

  methods PROCESS_DATA
    importing
      !IM_INPUT type Z01OTC_DT_RECEIVE_PRICE_RECOR1 .
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
  methods FEH_PREPARE
    importing
      !IM_INPUT type Z01OTC_DT_RECEIVE_PRICE_RECOR1 .
  methods CONSTRUCTOR .
  type-pools ABAP .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
protected section.
private section.

  class-data ATTRV_ECH_ACTION type ref to ZOTCCL_RECEIVEPRICE_LOAD .
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG'. "#EC NOTEXT
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .
ENDCLASS.



CLASS ZOTCCL_RECEIVEPRICE_LOAD IMPLEMENTATION.


method CONSTRUCTOR.
****************************************************************************
* Method     :CONSTRUCTOR
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&-----------------------------------------------------------------------

    CREATE OBJECT attrv_msg_container.
endmethod.


method feh_execute.
****************************************************************************
* Method     :FEH_EXECUTE
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&------------------------------------------------------------------------*


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
    else. " ELSE -> if im_ref_registration is bound
      lv_raise_exception = abap_true.
      lref_registration = cl_feh_registration=>s_initialize( is_single = space ).
    endif. " if im_ref_registration is bound

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
        endloop. " loop at attrv_feh_data assigning <lfs_feh_data>
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

    endif. " if lv_raise_exception = abap_true
  endif. " if lines( attrv_feh_data ) > 0
endmethod.


method FEH_PREPARE.
****************************************************************************
* Method     :FEH_PREPARE
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539 n                         *
*&------------------------------------------------------------------------*
    constants:lc_one              type ech_dte_objcat value '1',             "Object Category
              lc_ppm               type char3          value 'GAP',          " Gap of type CHAR3
              lc_obj_ppm           type char13         value 'OTC_IDD_0203'. " Obj_ppm of type CHAR13

    data:lwa_feh_data         type zca_feh_data                value is initial, "FEH Line
         lwa_ech_main_object  type ech_str_object              value is initial, "Object of Business Process
         li_applmsg           type applmsgtab                  value is initial, "Return Table for Messages
** Lr_data is used to in reference to proxy, so it can not be avoided
         lr_data              type ref to data                 value is initial, "Class
         lr_dref              type ref to data,                                  "  class
         lv_objkey            type ech_dte_objkey              value is initial, "Object Key
         lwa_bapiret          type bapiret2                    value is initial. "Return Parameter

    field-symbols: <lfs_appl_msg> type applmsg,                     "Return Structure for Messages
                   <lfs_input> type Z01OTC_DT_RECEIVE_PRICE_RECOR1. " Proxy Structure (generated)

    concatenate lc_obj_ppm
                lc_ppm
                 into lv_objkey separated by space.

* The error category should depends on the actually error not below testing category
    lwa_feh_data-error_category  = attrv_msg_container->get_err_category( ).
    lwa_ech_main_object-objcat   = lc_one.
    lwa_ech_main_object-objtype  = me->attrv_objtype.
    lwa_ech_main_object-objkey   = lv_objkey.
    lwa_feh_data-main_object     = lwa_ech_main_object.

    create data lr_dref type Z01OTC_DT_RECEIVE_PRICE_RECOR1. " Proxy Structure (generated)
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
endmethod.


method HAS_ERROR.
****************************************************************************
* Method     :HAS_ERROR
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&-----------------------------------------------------------------------

    re_result = attrv_msg_container->has_error( ).
endmethod.


method IF_ECH_ACTION~FAIL.
****************************************************************************
* Method     :IF_ECH_ACTION~FAIL
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&------------------------------------------------------------------------*

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
endmethod.


method IF_ECH_ACTION~FINALIZE_AFTER_RETRY_ERROR.
endmethod.


method IF_ECH_ACTION~FINISH.
****************************************************************************
* Method     :IF_ECH_ACTION~FINISH
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&------------------------------------------------------------------------*
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
endmethod.


method IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR.
endmethod.


method if_ech_action~retry.
****************************************************************************
* Method     :IF_ECH_ACTION~RETRY
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
*&-----------------------------------------------------------------------

**This method needs to be implemented to trigger the reprocessing of a message.
*The message will be called if Restart in Monitoring and Error Handling is
*clicked or if Repeat in Error  and  Conflict is selected

  data: lref_feh_registration  type ref to cl_feh_registration           value is initial,  "Registration and Restarting of FEH
        lx_input                type     z01otc_dt_receive_price_recor1  value is initial . "Z01OTC_MT_TRANSFER_PRICE_LOAD VALUE IS INITIAL.

  constants: lc_retry type bs_soa_siw_dte_proc_context  value 'RETRY'. "Processing context of service implementation

  clear e_execution_failed.
  clear e_return_message.

**Initialize business logic class
  me->initialize( im_id_processing_context = lc_retry ).

**Create FEH instance for RETRY
  lref_feh_registration = cl_feh_registration=>s_retry( i_error_object_id = i_error_object_id ).

**Retrieve data stored in FEH
  call method lref_feh_registration->retrieve_data
    exporting
      i_data              = i_data
    importing
      e_post_mapping_data = lx_input.

**Reprocess the data
  me->process_data( im_input = lx_input ).

**If still, there is error
  if me->has_error( ) = abap_true.
    me->feh_execute( im_ref_registration = lref_feh_registration ).
  endif. " IF me->has_error( ) = abap_true

**Update the FEH
  lref_feh_registration->resolve_retry( ).
endmethod.


method IF_ECH_ACTION~S_CREATE.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  GAP   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA   E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203   *
*&------------------------------------------------------------------------*
**This Generate Instance
    IF NOT attrv_ech_action IS BOUND.
      CREATE OBJECT attrv_ech_action.
    ENDIF. " IF NOT attrv_ech_action IS BOUND
    r_action_class = attrv_ech_action. "Class
endmethod.


method INITIALIZE.
***************************************************************************
* Method     :  INITIALIZE                                               *
* TITLE      :  Interface for receiving Price from  GAP   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA   E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203   *
*&------------------------------------------------------------------------*

    CONSTANTS : lc_retry    TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',   "Processing context of service implementation
                lc_fail     TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',    "Processing context of service implementation
                lc_finish   TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH',  "Processing context of service implementation
                lc_objtype  TYPE ech_dte_objtype             VALUE 'BUS2144', "Object Type
                lc_enh_name TYPE z_enhancement   VALUE 'OTC_IDD_0203'.        " Enhancement No.


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

endmethod.


METHOD process_data.
****************************************************************************
* Method     :EXECUTE
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539 n                         *
* 04-Oct-2017 MTHATHA  E1DK931014  Changes for SCTASK0521172              *
* 08-Feb-2019 AMOHAPA  E1DK939406  Defect#6163_INC0394429-02:While delete *
*                                  operation we should consider Valid From*
*                                  as well and Valid from/ valid To date  *
*                                  should be greater than today's date    *
* 02-Jul-2019 AMOHAPA   E2DK924543 Retrofit Defect#9397: Message Number   *
*                                  has changed from 890 to 888 as it has  *
*                                  already used in the upgarded system    *
* 05-Jul-2019 AMOHAPA  E2DK924543  Defect#10027: To comment the part of   *
*                                  code done for Defect#6163 as it will   *
*                                  move later to production               *
*&------------------------------------------------------------------------*
* Constants
  CONSTANTS:lc_matnr          TYPE z_criteria      VALUE 'MATNR',                  " Enh. Criteria
            lc_eztrac_gap     TYPE z_criteria      VALUE 'EZTRAC_GAP',               " Enh. Criteria
            lc_kschl_zb00     TYPE z_criteria      VALUE 'KSCHL_ZB00',               " Enh. Criteria
            lc_kschl_zf01     TYPE z_criteria      VALUE 'KSCHL_ZF01',               " Enh. Criteria
            lc_kschl_zm01     TYPE z_criteria      VALUE 'KSCHL_ZM01',               " Enh. Criteria
            lc_kbetr          TYPE z_criteria      VALUE 'KBETR'     ,               " Enh. Criteria
            lc_konwa          TYPE konwa           VALUE '%'         ,               " Rate unit (currency or percentage)
            lc_op_type_u      TYPE char1           VALUE 'U',                        "  Update
            lc_kvewe          TYPE kvewe           VALUE 'A',                        " Usage of the condition table
            lc_kappl          TYPE kappl           VALUE 'V',                        " Application
            lc_text_procedure TYPE z_criteria      VALUE 'TEXT_DETERMINE_PROCEDURE', " Enh. Criteria
            lc_id             TYPE z_criteria      VALUE 'TEXT_ID',                  " Enh. Criteria
            lc_bukrs_vkorg    TYPE z_criteria      VALUE 'BUKRS_VKORG'   ,           " Enh. Criteria
            lc_945            TYPE kotabnr         VALUE '945'  ,                    " Condition table
            lc_946            TYPE kotabnr         VALUE '946'  ,                    " Condition table
            lc_935            TYPE kotabnr         VALUE '935'  ,                    " Condition table
            lc_911            TYPE kotabnr         VALUE '911'  ,                    " Condition table
            lc_005            TYPE kotabnr         VALUE '005'  ,                    " Condition table
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
            lc_914            TYPE kotabnr         VALUE '914'  , " Condition table
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
            lc_del_op         TYPE msgfn           VALUE '003'  ,                    " Function
            lc_ins_op         TYPE msgfn           VALUE '009',                      " Function
            lc_cond_ins       TYPE knumh           VALUE '$000000001',               " Condition record number
            lc_msg            TYPE symsgno         VALUE '000',                      "Message Number
            lc_msg_197        TYPE symsgno         VALUE '197',                      "Message Number
            lc_msg_198        TYPE symsgno         VALUE '198',                      "Message Number
            lc_msg_199        TYPE symsgno         VALUE '199',                      "Message Number
            lc_msg_200        TYPE symsgno         VALUE '200',                      "Message Number
            lc_msg_201        TYPE symsgno         VALUE '201',                      "Message Number
            lc_msg_202        TYPE symsgno         VALUE '202',                      " Message Number
            lc_msg_203        TYPE symsgno         VALUE '203',                      "Message Number
            lc_msg_204        TYPE symsgno         VALUE '204',                      "Message Number
            lc_msg_205        TYPE symsgno         VALUE '205',                      "Message Number
            lc_msg_213        TYPE symsgno         VALUE '213',                      "Message Number
            lc_msg_214        TYPE symsgno         VALUE '214',                      "Message Number
            lc_msg_282        TYPE symsgno         VALUE '282',                      "Message Number
            lc_msg_215        TYPE symsgno         VALUE '215',                      "Message Number
            lc_msg_216        TYPE symsgno         VALUE '216',                      "Message Number
            lc_msg_217        TYPE symsgno         VALUE '217',                      "Message Number
            lc_error          TYPE char1           VALUE 'E',                        "Error
            lc_message        TYPE char24          VALUE 'IF_WSPROTOCOL_MESSAGE_ID', "XI: Message ID
            lc_sender         TYPE sxmspid         VALUE 'SENDER',                   "Integration Engine: Pipeline ID
            lc_name           TYPE sxms_extr_name  VALUE 'B_DOCU',                   "Extractor Name
            lc_success        TYPE char1           VALUE 'S',                        "Success  message
            lc_abort          TYPE char1           VALUE 'A',                        "Abort  message
            lc_kopos          TYPE kopos           VALUE '01',                       " Sequential number of the condition
            lc_krech          TYPE krech           VALUE 'C',                        " Calculation type for condition
            lc_krech_a        TYPE krech           VALUE 'A',                        " Calculation type for condition
            lc_op_type        TYPE char1           VALUE 'I',                        " Insert
            lc_object         TYPE tdobject        VALUE 'KONP',                     " Texts: Application Object
            lc_activity       TYPE cond_mnt_activity VALUE 'H',                      " Conditions: Maintenance Activity
            lc_dolaar         TYPE char2             VALUE '$$',                     " Dolaar of type CHAR2
            lc_temp_knumh     TYPE char10            VALUE 'TEMP_KNUMH'.             " Temp_knumh of type CHAR10

  DATA: li_proxy_in_item_tmp2  TYPE STANDARD TABLE OF lty_item,
        li_proxy_in_mvke       TYPE STANDARD TABLE OF lty_mvke,
        li_proxy_in_knvv       TYPE STANDARD TABLE OF lty_knvv,
        li_proxy_in_tcurc      TYPE STANDARD TABLE OF lty_tcurc,
        li_item_sele           TYPE STANDARD TABLE OF lty_item,
        li_bapicondct          TYPE STANDARD TABLE OF bapicondct,      " BAPI struct. for condition tables (corresponds to COND_RECS)
        li_bapicondhd          TYPE STANDARD TABLE OF bapicondhd,      " BAPI Structure of KONH with English Field Names
        li_bapicondit          TYPE STANDARD TABLE OF bapicondit,      " BAPI Structure of KONP with English Field Names
        li_bapicondqs          TYPE STANDARD TABLE OF bapicondqs,      " BAPI Structure of KONM with English Field Names
        li_bapicondvs          TYPE STANDARD TABLE OF bapicondvs,      " BAPI Structure of KONW with English Field Names
        li_bapiret2            TYPE STANDARD TABLE OF bapiret2,        " Return Parameter
        li_bapiknumhs          TYPE STANDARD TABLE OF bapiknumhs,      " BAPI Structure for Assignment of KNUMHs
        li_mem_initial         TYPE STANDARD TABLE OF cnd_mem_initial, " Conditions: Buffer for Initial Upload
        li_mvke                TYPE STANDARD TABLE OF lty_mvke,        " MVKE table
        li_knvv                TYPE STANDARD TABLE OF lty_knvv,
        li_con_945             TYPE STANDARD TABLE OF lty_con_945,     " Condition Table
        li_con_946             TYPE STANDARD TABLE OF lty_con_946,     " Condition Table
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
        li_con_914             TYPE STANDARD TABLE OF lty_con_914, " Condition Table
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
        li_con_935             TYPE STANDARD TABLE OF lty_con_935, " Condition Table
        li_con_005             TYPE STANDARD TABLE OF lty_con_005, " Condition Table
        li_tcurc               TYPE STANDARD TABLE OF lty_tcurc,
        lwa_mvke               TYPE lty_mvke,                      " Sales Data for Material
        lwa_knvv               TYPE lty_knvv,                      " Customer data for sales
        lwa_bapicondct         TYPE bapicondct,                    " BAPI struct. for condition tables (corresponds to COND_RECS)
        lwa_bapicondhd         TYPE bapicondhd,                    " BAPI Structure of KONH with English Field Names
        lwa_bapicondit         TYPE bapicondit,                    " BAPI Structure of KONP with English Field Names
        lwa_bapiret2           TYPE bapiret2,                      " Return Parameter
        lwa_item               TYPE lty_item,                      " Items
        lwa_tcurc              TYPE lty_tcurc,
        lwa_text_create        TYPE lty_text_create,
        lv_matnr               TYPE matnr,                         " Material Number
        lv_kschl               TYPE kschl,                         " Condition Type
        lv_kotabnr             TYPE kotabnr ,                      " Condition table
        lv_skip                TYPE char1,                         " Skip of type CHAR1
        lv_commit_fail         TYPE char1,                         " No commit
        lv_physically_del      TYPE xfeld        ,                 " Checkbox
        lwa_line               TYPE  tline   ,                     " SAPscript: Text Lines
        li_text_create         TYPE STANDARD TABLE OF lty_text_create,
        li_line                TYPE STANDARD TABLE OF    tline ,   " SAPscript: Text Lines
        lv_count               TYPE i,                             " Count
        lv_date                TYPE datum,                         " Date
* FEH related  declaration
        lref_oref              TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
        lref_server_cntxt      TYPE REF TO if_ws_server_context         VALUE IS INITIAL, "Proxy Server Context
        lref_wsprotocol_msg_id TYPE REF TO if_wsprotocol_message_id     VALUE IS INITIAL, "XI and WS: Read Message ID
        lref_protocol          TYPE REF TO if_wsprotocol                VALUE IS INITIAL, "ABAP Proxies: Available Protocols
        lref_cx_root           TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
        li_sxmspdata           TYPE STANDARD TABLE OF sxmspdata         INITIAL SIZE 0,   "Archive for Message Extract
        lwa_sxmspdata          TYPE sxmspdata                           VALUE IS INITIAL, "Archive for Message Extract
        lwa_bapi_msg           TYPE bapiret2                            VALUE IS INITIAL, "Return Parameter
        lv_protocol_name       TYPE string                              VALUE IS INITIAL, "Protocol Name
        lv_xml_message_id      TYPE sxmsmguid                           VALUE IS INITIAL, "XI: Message ID
        lv_text                TYPE string                              VALUE IS INITIAL, "String
        li_konh                TYPE TABLE OF  konh,                                       " Conditions (Header)
        li_konp                TYPE TABLE OF konp,                                        " Conditions (Item)
        lwa_konh               TYPE konh,                                                 " Conditions (Header)
        lwa_konp               TYPE konp,                                                 " Conditions (Item)
        lwa_task               TYPE vkon_task_key,                                        " Admin. and Appl. (Task) of Condition Technique
        li_messages            TYPE cond_mnt_message_t,
        li_messages1           TYPE cond_mnt_message_t,
        lwa_message            TYPE cond_mnt_message,                                     " Condition Maintenance: Message Structure
        lv_subrc               TYPE cond_mnt_result,                                      " Result of Condition Maintenance
        lwa_price_data         TYPE price_details,                                        " Inbound proxy price details
        lv_handle              TYPE sytabix,                                              " Index of Internal Tables
        li_selection           TYPE cl_cond_tab_sel=>cond_rngs_t,
        lv_temp_knumh_mem1     TYPE char060,                                              " Knumh_mem1(60) of type Character
        lv_knumh               TYPE konh-knumh VALUE '0000000000',                        " Condition record number
        lv_modno               TYPE char12,                                               " Modno(12) of type Character
        lwa_record             TYPE cond_mnt_record_data,                                 " Condition Maintenance: Condition Record (Key and Data)
        lv_recno               TYPE syloopc,                                              " Visible Lines of a Step Loop
        li_record_keys         TYPE cond_mnt_record_key_t,
        lwa_record_key         TYPE cond_mnt_record_key,                                  " Condition Maintenance: ID and Key of a Condition Record
        lr_cond_utils          TYPE REF TO cl_cond_mnt_util_a,                            " Utilities for Price Maintenance
        lv_current_number1     TYPE char04,                                               " Current_number1(4) of type Character
        lv_kbetr               TYPE kbetr_kond,                                           " Rate (condition amount or percentage) where no scale exists
        li_con_005_zm01        TYPE STANDARD TABLE OF lty_con_005.                        " Condition Table

* Field Symbols
  FIELD-SYMBOLS  : <lfs_constants>   TYPE zdev_enh_status                 , " Enhancement Status
                   <lfs_bapiret2>    TYPE bapiret2 ,                        " Return Parameter
                   <lfs_con_945>     TYPE lty_con_945,                      " Condition  table
                   <lfs_con_946>     TYPE lty_con_946,                      " Condition  table
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                   <lfs_con_914>     TYPE lty_con_914, " Condition  table
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                   <lfs_con_935>     TYPE lty_con_935,         " Condition  table
                   <lfs_con_005>     TYPE lty_con_005,         " Condition  table
                   <lfs_text_create> TYPE lty_text_create,
                   <lfs_record_key>  TYPE cond_mnt_record_key. " Condition Maintenance: ID and Key of a Condition Record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
  "Local constant declarations
*  CONSTANTS:
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of delete for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*               lc_msg_890 TYPE symsgno     VALUE '890', "Message Number
*<--End of delete for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of insert for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*    lc_msg_888 TYPE symsgno     VALUE '888', "Message Number
*<--End of insert for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*    lc_zero    TYPE char1       VALUE '0'.   "constant for zero
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019

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

  CLEAR:li_proxy_in_item_tmp2[],
           li_proxy_in_mvke[],
           li_proxy_in_knvv[],
           li_proxy_in_tcurc[],
           li_item_sele[],
           li_bapicondct[],
           li_bapicondhd[],
           li_bapicondit[],
           li_bapicondqs[],
           li_bapicondvs[],
           li_bapiret2[],
           li_bapiknumhs[],
           li_mem_initial[],
           li_mvke[],
           li_knvv[],
           li_con_945[],
           li_con_946[],
           li_con_935[],
           li_con_005[],
           li_tcurc[],
           lwa_mvke,
           lwa_knvv,
           lwa_bapicondct,
           lwa_bapicondhd,
           lwa_bapicondit,
           lwa_bapiret2,
           lwa_item,
           lwa_tcurc,
           lwa_text_create,
           lv_matnr,
           lv_kschl,
           lv_kotabnr,
           lv_skip,
           lv_commit_fail,
           lv_physically_del,
           lwa_line,
           li_text_create[],
           li_line[],
           lv_count,
           lv_date,
* FEH related  declaration
          lref_oref,
          lref_server_cntxt,
          lref_wsprotocol_msg_id ,
          lref_protocol,
          lref_cx_root,
          li_sxmspdata,
          lwa_sxmspdata,
          lwa_bapi_msg,
          lv_protocol_name,
          lv_xml_message_id,
          lv_text,
          li_konh[],
          li_konp[],
          lwa_konh,
          lwa_konp,
          lwa_task,
          li_messages[],
          li_messages1[],
          lwa_message,
          lv_subrc,
          lwa_price_data,
          lv_handle,
          li_selection[],
          lv_temp_knumh_mem1 ,
          lv_knumh,
          lv_modno,
          lwa_record,
          lv_recno,
          li_record_keys[],
          lwa_record_key,
          lr_cond_utils,
          lv_current_number1,
          lv_kbetr,
          li_con_005_zm01[].

* Pass on the message data to local variable
  lwa_item-kunnr = im_input-customer_code.
  lwa_item-kunwe = im_input-ship_to.
  lwa_item-datab = im_input-start_date.
  lwa_item-datbi = im_input-end_date.
  lwa_item-matnr = im_input-item_code.
  lwa_item-kbetr = im_input-item_price.
  lwa_item-konwa = im_input-currency.
  lwa_item-ztext = im_input-quote_id.
  lwa_item-vkorg = im_input-country.
  lwa_item-vtweg = '10'.
  IF im_input-deletion = 'D'.
    lwa_item-loevm_ko = 'X'.
  ENDIF. " IF im_input-deletion = 'D'
  lwa_item-kpein = '1'.
  lwa_item-kmein = 'EA'.

* Populate Sales organisation details from country  code
  READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
              WITH KEY criteria = lc_bukrs_vkorg
                       sel_low  = lwa_item-vkorg
                       active   = abap_true.
  IF sy-subrc IS INITIAL.
    lwa_item-vkorg = <lfs_constants>-sel_high .
* Popuate sold to party and ship to party
    IF lwa_item-kunnr  IS  NOT INITIAL .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lwa_item-kunnr
        IMPORTING
          output = lwa_item-kunnr.
    ENDIF. " IF lwa_item-kunnr IS NOT INITIAL

    IF lwa_item-kunwe   IS  NOT INITIAL .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lwa_item-kunwe
        IMPORTING
          output = lwa_item-kunwe.
    ENDIF. " IF lwa_item-kunwe IS NOT INITIAL


    IF lwa_item-loevm_ko  IS INITIAL.
* Populate MVKE selection table
      lwa_mvke-matnr   = lwa_item-matnr .
      lwa_mvke-vkorg   = lwa_item-vkorg .
      lwa_mvke-vtweg   = lwa_item-vtweg .
      APPEND  lwa_mvke TO li_proxy_in_mvke.
      CLEAR lwa_mvke .
* Populate Currency table
      lwa_tcurc-waers =  lwa_item-konwa .
      APPEND  lwa_tcurc TO li_proxy_in_tcurc.
      CLEAR lwa_tcurc   .

* Populate KNVV selection table for  Sold to party
      IF lwa_item-kunnr  IS   NOT INITIAL.
        lwa_knvv-kunnr   = lwa_item-kunnr .
        lwa_knvv-vkorg   = lwa_item-vkorg .
        lwa_knvv-vtweg   = lwa_item-vtweg .
        APPEND  lwa_knvv TO li_proxy_in_knvv.
        CLEAR lwa_knvv .
      ENDIF. " IF lwa_item-kunnr IS NOT INITIAL

* Populate KNVV selection table for Ship to Party
      IF lwa_item-kunwe  IS   NOT INITIAL.
        lwa_knvv-kunnr   = lwa_item-kunwe .
        lwa_knvv-vkorg   = lwa_item-vkorg .
        lwa_knvv-vtweg   = lwa_item-vtweg .
        APPEND  lwa_knvv TO li_proxy_in_knvv.
        CLEAR lwa_knvv  .
      ENDIF. " IF lwa_item-kunwe IS NOT INITIAL
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02    by AMOHAPA on 08-Feb-2019
      "If Deletion indicator is there with the record then it should process the record where
      "valid from and valid to both the date are in future
*    ELSE. " ELSE -> IF lwa_item-loevm_ko IS INITIAL
*      IF lwa_item-datab LT sy-datum OR
*         lwa_item-datbi LT sy-datum.
*        "if valid from date is in past then it should go to error saying Past Record
*        SHIFT lwa_item-kunnr LEFT DELETING LEADING lc_zero.
*        lv_commit_fail =  abap_true    .
*        lv_skip   = abap_true.
*        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
*        lwa_bapi_msg-id         = attrc_msgid.
**-->Begin of delete for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
**        lwa_bapi_msg-number     = lc_msg_890.
**<--End of delete for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
**-->Begin of insert for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*        lwa_bapi_msg-number     = lc_msg_888.  "message number
**<--End of insert for D3_OTC_IDD_0203_Defect#9397_INC0394429-05 by AMOHAPA on 02-Jul-2019
*        lwa_bapi_msg-message_v1 = lwa_item-kunnr.
*        lwa_bapi_msg-message_v2 = lwa_item-matnr.
*        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
*        CLEAR: lwa_bapi_msg.
*      ENDIF. " IF lwa_item-datab LT sy-datum OR
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02    by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
    ENDIF. " IF lwa_item-loevm_ko IS INITIAL
* Popoulate selection table for  condition
    APPEND lwa_item TO li_item_sele.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
* If Sales organisation not found for country code , populate error message in FEH
    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
    lwa_bapi_msg-id         = attrc_msgid.
    lwa_bapi_msg-number     = lc_msg_200.
    lwa_bapi_msg-message_v1 = lwa_item-vkorg.
    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    CLEAR: lwa_bapi_msg,
           lwa_item-vkorg .
  ENDIF. " IF sy-subrc IS INITIAL

* Validation of To date
  lv_date = lwa_item-datbi .
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
    lwa_bapi_msg-id         = attrc_msgid.
    lwa_bapi_msg-number     = lc_msg_213.
    lwa_bapi_msg-message_v1 = lwa_item-datbi.
    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    CLEAR:  lwa_bapi_msg,
            lv_date.
  ENDIF. " IF sy-subrc <> 0
* Validation of From Date
  lv_date = lwa_item-datab .
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
    lwa_bapi_msg-id         = attrc_msgid.
    lwa_bapi_msg-number     = lc_msg_214.
    lwa_bapi_msg-message_v1 = lwa_item-datab.
    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    CLEAR:  lwa_bapi_msg,lv_date.
  ENDIF. " IF sy-subrc <> 0

* Get the entries  from MVKE table to validate  material and sales organisation
  SORT    li_proxy_in_mvke  BY matnr vkorg  vtweg.
  DELETE ADJACENT DUPLICATES FROM li_proxy_in_mvke COMPARING matnr vkorg  vtweg .

  IF li_proxy_in_mvke  IS NOT  INITIAL .
    SELECT matnr " Material Number
           vkorg " Sales Organization
           vtweg " Distribution Channel
    FROM   mvke  " Sales Data for Material
    INTO TABLE li_mvke
    FOR ALL ENTRIES IN   li_proxy_in_mvke
    WHERE matnr = li_proxy_in_mvke-matnr
    AND  vkorg = li_proxy_in_mvke-vkorg
    AND  vtweg = li_proxy_in_mvke-vtweg  .
*        If found
    IF sy-subrc IS   INITIAL .
      SORT li_mvke BY matnr vkorg vtweg.
    ENDIF. " IF sy-subrc IS INITIAL
    FREE:  li_proxy_in_mvke .
  ENDIF. " IF li_proxy_in_mvke IS NOT INITIAL

*--begin of comment
* Get the entries  from MVKE table to validate  material and sales organisation
  SORT    li_proxy_in_tcurc  BY waers.
  DELETE ADJACENT DUPLICATES FROM li_proxy_in_tcurc COMPARING waers.
*--End of comment

  IF li_proxy_in_tcurc  IS NOT  INITIAL .
    SELECT waers " Material Number
    FROM   tcurc " Sales Data for Material
    INTO TABLE li_tcurc
    FOR ALL ENTRIES IN   li_proxy_in_tcurc
    WHERE waers = li_proxy_in_tcurc-waers   .
*        If found
    IF sy-subrc IS   INITIAL .
      SORT li_tcurc BY waers.
    ENDIF. " IF sy-subrc IS INITIAL
    FREE:  li_proxy_in_tcurc .
  ENDIF. " IF li_proxy_in_tcurc IS NOT INITIAL


* Get the entries  from MVKE table to validate  material and sales organisation
  SORT    li_proxy_in_knvv   BY kunnr  vkorg  vtweg.
  DELETE ADJACENT DUPLICATES FROM li_proxy_in_knvv COMPARING kunnr  vkorg  vtweg .
*This select is for Validation only- Subset of the keys is required to be validated. hence
*only that subset is selected by adding the same  the same subset in the where clause .
*Hence no data loss  will happen.So  full set is not required to be selected for this FAE
  IF li_proxy_in_knvv   IS NOT  INITIAL .
    SELECT kunnr " Material Number
           vkorg " Sales Organization
           vtweg " Distribution Channel
    FROM   knvv  " Sales Data for Material
    INTO TABLE li_knvv
    FOR ALL ENTRIES IN   li_proxy_in_knvv
    WHERE kunnr  = li_proxy_in_knvv-kunnr
    AND  vkorg   = li_proxy_in_knvv-vkorg
    AND  vtweg   = li_proxy_in_knvv-vtweg  .

*        If found
    IF sy-subrc IS   INITIAL .
      SORT li_knvv BY kunnr vkorg vtweg.
    ENDIF. " IF sy-subrc IS INITIAL
    FREE:  li_proxy_in_knvv .
  ENDIF. " IF li_proxy_in_knvv IS NOT INITIAL


* Check the material is in EMI table, if it is there , then it is condition type ZF01, else ZB00
  READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
   WITH KEY criteria =  lc_matnr
             active = abap_true.
  IF sy-subrc IS INITIAL.
    lv_matnr = <lfs_constants>-sel_low.
    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                WITH KEY criteria =    lc_kschl_zf01
                         active = abap_true.
    IF sy-subrc IS  INITIAL.
      lv_kschl = <lfs_constants>-sel_low.

* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 946 will select.
      li_proxy_in_item_tmp2  = li_item_sele   .

      DELETE li_proxy_in_item_tmp2 WHERE loevm_ko IS INITIAL.
      DELETE li_proxy_in_item_tmp2 WHERE matnr NE lv_matnr.
      DELETE li_proxy_in_item_tmp2 WHERE kunwe IS NOT INITIAL .
      SORT li_proxy_in_item_tmp2 BY vkorg
                                    vtweg
                                    kunnr
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                                    kunwe
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                                    datbi.
      DELETE ADJACENT DUPLICATES FROM li_proxy_in_item_tmp2
                         COMPARING  vkorg
                                    vtweg
                                    kunnr
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                                    kunwe
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
                                    datbi.


      IF li_proxy_in_item_tmp2 IS NOT INITIAL.
        SELECT kappl " Application
               kschl " Condition type
               vkorg " Sales Organization
               vtweg " Distribution Channel
               kunag " Sold-to party
               datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*               datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
               knumh " Condition record number
           FROM a946 " Customer/Material
           INTO TABLE  li_con_946
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunag =  li_proxy_in_item_tmp2-kunnr
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_946  BY kappl kschl vkorg vtweg kunag datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                               datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
        CLEAR  li_proxy_in_item_tmp2    .
      ENDIF. " IF li_proxy_in_item_tmp2 IS NOT INITIAL

*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
      IF li_proxy_in_item_tmp2 IS NOT INITIAL.
        SELECT kappl " Application
               kschl " Condition type
               vkorg " Sales Organization
               vtweg " Distribution Channel
               kunwe " Sold-to party
               datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*               datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
               knumh " Condition record number
           FROM a914 " Customer/Material
           INTO TABLE  li_con_914
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunwe =  li_proxy_in_item_tmp2-kunwe
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_914  BY kappl kschl vkorg vtweg kunwe datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                              datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
        CLEAR  li_proxy_in_item_tmp2    .
      ENDIF. " IF li_proxy_in_item_tmp2 IS NOT INITIAL
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
* Select all the condition record no from condition table for delete operation. If ship to party is there, then condition 945 will select.
      li_proxy_in_item_tmp2  = li_item_sele   .

      DELETE li_proxy_in_item_tmp2 WHERE loevm_ko IS INITIAL.
      DELETE li_proxy_in_item_tmp2 WHERE matnr NE lv_matnr.
      DELETE li_proxy_in_item_tmp2 WHERE kunwe IS INITIAL.
      SORT li_proxy_in_item_tmp2 BY vkorg
                                    vtweg
                                    kunnr
                                    kunwe
                                    datbi.
      DELETE ADJACENT DUPLICATES FROM li_proxy_in_item_tmp2
                         COMPARING  vkorg
                                    vtweg
                                    kunnr
                                    kunwe
                                    datbi.

      IF li_proxy_in_item_tmp2 IS NOT INITIAL.

        SELECT  kappl " Application
                kschl " Condition type
                vkorg " Sales Organization
                vtweg " Distribution Channel
                kunag " Sold-to party
                kunwe " Ship-to party
                datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                knumh " Condition record number
           FROM a945  " Customer/Material
           INTO TABLE  li_con_945
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunag =  li_proxy_in_item_tmp2-kunnr
          AND      kunwe =  li_proxy_in_item_tmp2-kunwe
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_945  BY kappl kschl vkorg vtweg kunag kunwe datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                                    datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF . " IF li_proxy_in_item_tmp2 IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
              WITH KEY criteria =    lc_kschl_zb00
                       active = abap_true.
    IF sy-subrc IS  INITIAL.

      lv_kschl = <lfs_constants>-sel_low.
      CLEAR li_proxy_in_item_tmp2 .
* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 005 will select.
      li_proxy_in_item_tmp2  = li_item_sele   .
*  Consider only item which  value is not initial
      DELETE li_proxy_in_item_tmp2 WHERE kbetr EQ '0.00'.
      DELETE li_proxy_in_item_tmp2 WHERE loevm_ko IS INITIAL.
      DELETE li_proxy_in_item_tmp2 WHERE matnr EQ lv_matnr.
      DELETE li_proxy_in_item_tmp2 WHERE kunwe IS NOT INITIAL .
      SORT li_proxy_in_item_tmp2 BY vkorg
                                    vtweg
                                    kunnr
                                    matnr
                                    datbi.
      DELETE ADJACENT DUPLICATES FROM li_proxy_in_item_tmp2
                         COMPARING  vkorg
                                    vtweg
                                    kunnr
                                    matnr
                                    datbi.
      IF li_proxy_in_item_tmp2 IS NOT INITIAL.

        SELECT kappl " Application
               kschl " Condition type
               vkorg " Sales Organization
               vtweg " Distribution Channel
               kunnr " Customer number
               matnr " Material Number
               datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*               datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
               knumh " Condition record number
           FROM a005 " Customer/Material
           INTO TABLE  li_con_005
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunnr =  li_proxy_in_item_tmp2-kunnr
          AND      matnr =  li_proxy_in_item_tmp2-matnr
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_005  BY kappl kschl vkorg vtweg  kunnr matnr  datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                                      datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
        CLEAR li_proxy_in_item_tmp2    .

      ENDIF. " IF li_proxy_in_item_tmp2 IS NOT INITIAL

* Select all the condition record no from condition table for delete operation. If ship to party is there, then condition 935 will select.
      li_proxy_in_item_tmp2  = li_item_sele   .
      DELETE li_proxy_in_item_tmp2 WHERE loevm_ko IS INITIAL.
      DELETE li_proxy_in_item_tmp2 WHERE matnr EQ lv_matnr.
      DELETE li_proxy_in_item_tmp2 WHERE kunwe IS INITIAL.
      SORT li_proxy_in_item_tmp2 BY vkorg
                                    vtweg
                                    kunnr
                                    kunwe
                                    matnr
                                    datbi.
      DELETE ADJACENT DUPLICATES FROM li_proxy_in_item_tmp2
                         COMPARING  vkorg
                                    vtweg
                                    kunnr
                                    kunwe
                                    matnr
                                    datbi.

      IF li_proxy_in_item_tmp2 IS NOT INITIAL.

        SELECT kappl " Application
               kschl " Condition type
               vkorg " Sales Organization
               vtweg " Distribution Channel
               kunag " Sold-to party
               kunwe " Ship-to party
               matnr " Material Number
               datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*               datab " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
               knumh " Condition record number
           FROM a935 " Customer/Material
           INTO TABLE  li_con_935
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunag =  li_proxy_in_item_tmp2-kunnr
          AND      kunwe =  li_proxy_in_item_tmp2-kunwe
          AND      matnr =  li_proxy_in_item_tmp2-matnr
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_935  BY kappl kschl vkorg vtweg kunag   kunwe matnr  datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                                             datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF li_proxy_in_item_tmp2 IS NOT INITIAL
    ENDIF . " IF sy-subrc IS INITIAL
* Populate condition type for ZM01
    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
              WITH KEY criteria =    lc_kschl_zm01
                       active = abap_true.
    IF sy-subrc IS  INITIAL.

      lv_kschl = <lfs_constants>-sel_low.
      CLEAR li_proxy_in_item_tmp2 .
* Select all the condition record no from condition table for delete operation. If ship to party not there, then condition 005 will select.
      li_proxy_in_item_tmp2  = li_item_sele   .
      DELETE li_proxy_in_item_tmp2 WHERE kbetr NE 0 .
      DELETE li_proxy_in_item_tmp2 WHERE loevm_ko IS INITIAL.
      DELETE li_proxy_in_item_tmp2 WHERE matnr EQ lv_matnr.
      DELETE li_proxy_in_item_tmp2 WHERE kunwe IS NOT INITIAL .
      SORT li_proxy_in_item_tmp2 BY vkorg
                                    vtweg
                                    kunnr
                                    matnr
                                    datbi.
      DELETE ADJACENT DUPLICATES FROM li_proxy_in_item_tmp2
                         COMPARING  vkorg
                                    vtweg
                                    kunnr
                                    matnr
                                    datbi.
      IF li_proxy_in_item_tmp2 IS NOT INITIAL.

        SELECT kappl " Application
               kschl " Condition type
               vkorg " Sales Organization
               vtweg " Distribution Channel
               kunnr " Customer number
               matnr " Material Number
               datbi " Validity end date of the condition record
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*               datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
               knumh " Condition record number
           FROM a005 " Customer/Material
           INTO TABLE  li_con_005_zm01
          FOR ALL ENTRIES IN li_proxy_in_item_tmp2
          WHERE    kappl =  lc_kappl
          AND      kschl =  lv_kschl
          AND      vkorg =  li_proxy_in_item_tmp2-vkorg
          AND      vtweg =  li_proxy_in_item_tmp2-vtweg
          AND      kunnr =  li_proxy_in_item_tmp2-kunnr
          AND      matnr =  li_proxy_in_item_tmp2-matnr
          AND      datbi =  li_proxy_in_item_tmp2-datbi.
        IF sy-subrc IS INITIAL.
          SORT   li_con_005_zm01  BY kappl kschl vkorg vtweg  kunnr matnr  datbi.
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                                                           datab.
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
        ENDIF. " IF sy-subrc IS INITIAL
        CLEAR li_proxy_in_item_tmp2    .

      ENDIF. " IF li_proxy_in_item_tmp2 IS NOT INITIAL
    ENDIF . " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

  FREE: li_proxy_in_item_tmp2,
        li_item_sele.

  lv_kbetr = lwa_item-kbetr.
* If material is there, then condition type is ZF01
  READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
              WITH KEY criteria =  lc_matnr
                       sel_low = lwa_item-matnr
                       active = abap_true.
  IF sy-subrc IS INITIAL.
    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                WITH KEY criteria =    lc_kschl_zf01
                         active = abap_true.
    IF sy-subrc IS  INITIAL.
      lv_kschl = <lfs_constants>-sel_low.
* If sold to party and ship to party is there then 945 condition  table
      IF lwa_item-kunnr IS  NOT INITIAL AND
         lwa_item-kunwe IS NOT INITIAL.

        lv_kotabnr  = lc_945.
* If sold to party is there  and ship to party is not there then 946 condition  table

      ELSEIF lwa_item-kunnr IS NOT INITIAL  AND
             lwa_item-kunwe IS INITIAL.

        lv_kotabnr  = lc_946 .
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
      ELSEIF lwa_item-kunnr IS INITIAL  AND
             lwa_item-kunwe IS NOT INITIAL.
        lv_kotabnr  = lc_914.
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
      ENDIF. " IF lwa_item-kunnr IS NOT INITIAL AND
    ENDIF. " IF sy-subrc IS INITIAL

* If KBETER is initial  and ship to party not provide, populate condition type ZM01
  ELSEIF lv_kbetr EQ '0.00'.
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
*     AND
*        lwa_item-kunwe IS INITIAL.
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
* If material is not  there, then condition type is  ZM01
    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                WITH KEY criteria =    lc_kschl_zm01
                         active = abap_true.
    IF sy-subrc EQ 0.
      lv_kschl = <lfs_constants>-sel_low.
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
*      lv_kotabnr  = lc_005 .
* If sold to party and ship to party is there then 935 condition  table
      IF lwa_item-kunnr IS  NOT INITIAL AND
         lwa_item-kunwe IS NOT INITIAL.
        lv_kotabnr  = lc_935.
* If sold to party is there  and ship to party is not there then 005 condition  table
      ELSEIF lwa_item-kunnr IS NOT INITIAL  AND
             lwa_item-kunwe IS INITIAL.
        lv_kotabnr  = lc_005 .
* If sold to party is tnot here  and ship to party is there then 911 condition  table
      ELSEIF  lwa_item-kunnr IS INITIAL  AND
              lwa_item-kunwe IS NOT INITIAL.
        lv_kotabnr  = lc_911 .
      ENDIF. " IF lwa_item-kunnr IS NOT INITIAL AND
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
    ENDIF. " IF sy-subrc EQ 0
  ELSE . " ELSE -> IF sy-subrc IS INITIAL
* If material is not  there, then condition type is ZB00
    READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                WITH KEY criteria =    lc_kschl_zb00
                         active = abap_true.
    IF sy-subrc EQ 0.
      lv_kschl = <lfs_constants>-sel_low.
* If sold to party and ship to party is there then 935 condition  table
      IF lwa_item-kunnr IS  NOT INITIAL AND
         lwa_item-kunwe IS NOT INITIAL.
        lv_kotabnr  = lc_935.
* If sold to party is there  and ship to party is not there then 005 condition  table
      ELSEIF lwa_item-kunnr IS NOT INITIAL  AND
             lwa_item-kunwe IS INITIAL.
        lv_kotabnr  = lc_005 .
* If sold to party is tnot here  and ship to party is there then 911 condition  table
      ELSEIF  lwa_item-kunnr IS INITIAL  AND
              lwa_item-kunwe IS NOT INITIAL.
        lv_kotabnr  = lc_911 .
      ENDIF. " IF lwa_item-kunnr IS NOT INITIAL AND
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc IS INITIAL

  IF lv_kotabnr IS INITIAL.
    lwa_bapi_msg-type       = zcacl_message_container=>c_error.
    lwa_bapi_msg-id         = attrc_msgid.
    lwa_bapi_msg-number     = lc_msg_282.
    lwa_bapi_msg-message_v1 = lwa_item-kunnr.
    lwa_bapi_msg-message_v2 = lwa_item-kunwe.
    me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    CLEAR:lwa_bapi_msg.
  ENDIF. " IF lv_kotabnr IS INITIAL
* Prepare FEH error
  IF me->has_error( ) = abap_true.
    me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
    me->feh_prepare( im_input ).
    EXIT.
  ENDIF. " IF me->has_error( ) = abap_true

* Populate the Condition table
  lwa_bapicondct-table_no = lv_kotabnr .
  lwa_bapicondhd-table_no = lv_kotabnr.

* Populate the VARKEY
  CASE lv_kotabnr .
    WHEN lc_945 .
      CONCATENATE     lwa_item-vkorg
       lwa_item-vtweg
       lwa_item-kunnr
       INTO lwa_bapicondct-varkey.
      lwa_bapicondct-varkey+16 =  lwa_item-kunwe .
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
    WHEN lc_946.
      CONCATENATE     lwa_item-vkorg
                      lwa_item-vtweg
                      lwa_item-kunnr
                   INTO lwa_bapicondct-varkey.
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
    WHEN lc_914.
      CONCATENATE     lwa_item-vkorg
                      lwa_item-vtweg
                      lwa_item-kunwe
                   INTO lwa_bapicondct-varkey.
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
    WHEN lc_935.
      CONCATENATE     lwa_item-vkorg
                      lwa_item-vtweg
                      lwa_item-kunnr
                      INTO lwa_bapicondct-varkey.
      lwa_bapicondct-varkey+16 =  lwa_item-kunwe .
      lwa_bapicondct-varkey+26 =  lwa_item-matnr.
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
    WHEN lc_005.
      CONCATENATE     lwa_item-vkorg
                      lwa_item-vtweg
                      lwa_item-kunnr
                      INTO lwa_bapicondct-varkey.
      lwa_bapicondct-varkey+16 = lwa_item-matnr.
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
    WHEN lc_911.
      CONCATENATE     lwa_item-vkorg
                      lwa_item-vtweg
                      lwa_item-kunwe
                      INTO lwa_bapicondct-varkey.
      lwa_bapicondct-varkey+16 =  lwa_item-matnr.
      lwa_bapicondhd-varkey = lwa_bapicondct-varkey.
    WHEN OTHERS .
*        Do nothing
  ENDCASE .

  IF lwa_item-loevm_ko   IS INITIAL.
* Check  Sales organsiation and material validation not in  MVKE table
    IF lv_kotabnr EQ lc_935 OR
       lv_kotabnr EQ lc_005 .
      SORT li_mvke BY matnr vkorg vtweg.
      READ TABLE li_mvke
      WITH KEY  matnr  = lwa_item-matnr
                vkorg  = lwa_item-vkorg
                vtweg  = lwa_item-vtweg
               TRANSPORTING NO FIELDS
                BINARY SEARCH .
      IF sy-subrc IS  NOT  INITIAL.
        lv_commit_fail =  abap_true    .
        lv_skip = abap_true.
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg_198.
        lwa_bapi_msg-message_v1 = lwa_item-matnr.
        lwa_bapi_msg-message_v2 = lwa_item-vkorg.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF lv_kotabnr EQ lc_935 OR
* Check  Sold  to Party and Sales  Organisation validation not in  KNVV table
    IF lwa_item-kunnr IS NOT INITIAL .
      SORT li_knvv BY kunnr vkorg vtweg.
      READ TABLE li_knvv
      WITH KEY  kunnr  = lwa_item-kunnr
                vkorg  = lwa_item-vkorg
                vtweg  = lwa_item-vtweg
               TRANSPORTING NO FIELDS
                BINARY SEARCH .
      IF sy-subrc IS  NOT  INITIAL.
        lv_commit_fail =  abap_true    .
        lv_skip = abap_true.
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg_216.
        lwa_bapi_msg-message_v1 = lwa_item-kunnr .
        lwa_bapi_msg-message_v2 = lwa_item-vkorg.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF lwa_item-kunnr IS NOT INITIAL
* Check  Ship to Party and Sales  Organisation validation not in  KNVV table
    IF  lwa_item-kunwe IS   NOT INITIAL.
      SORT li_knvv BY kunnr vkorg vtweg.
      READ TABLE li_knvv
      WITH KEY  kunnr  = lwa_item-kunwe
                vkorg  = lwa_item-vkorg
                vtweg  = lwa_item-vtweg
               TRANSPORTING NO FIELDS
                BINARY SEARCH .
      IF sy-subrc IS  NOT  INITIAL.
        lv_commit_fail =  abap_true    .
        lv_skip = abap_true.
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg_215.
        lwa_bapi_msg-message_v1 = lwa_item-kunwe .
        lwa_bapi_msg-message_v2 = lwa_item-vkorg.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF lwa_item-kunwe IS NOT INITIAL
    SORT li_tcurc BY waers.
*  Currency key  validation
    READ TABLE li_tcurc
    WITH KEY  waers  = lwa_item-konwa
             TRANSPORTING NO FIELDS
              BINARY SEARCH .
    IF sy-subrc IS  NOT  INITIAL.
      lv_commit_fail =  abap_true    .
      lv_skip = abap_true.
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg_217.
      lwa_bapi_msg-message_v1 = lwa_item-konwa .
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF lwa_item-loevm_ko IS INITIAL
* If Condition records need to  insert
  IF lwa_item-loevm_ko IS  INITIAL.
    lwa_bapicondct-operation = lc_ins_op.
    lwa_bapicondct-cond_no =  lc_cond_ins.
    lwa_bapicondhd-operation = lc_ins_op.
    lwa_bapicondhd-cond_no = lc_cond_ins.
    lwa_bapicondit-operation = lc_ins_op.
    lwa_bapicondit-cond_no = lc_cond_ins .
    lwa_bapicondit-cond_count = lc_kopos.
    lwa_bapicondhd-created_by = sy-uname.
    lwa_bapicondhd-creat_date = sy-datum.
    lwa_bapicondhd-valid_from = lwa_item-datab .
    lwa_bapicondhd-valid_to = lwa_item-datbi.
  ELSE. " ELSE -> IF lwa_item-loevm_ko IS INITIAL
* If Condition records need to delete
    CASE  lv_kotabnr  .
      WHEN lc_945.
        READ TABLE li_con_945 ASSIGNING <lfs_con_945>
                   WITH KEY     kappl =  lc_kappl
                                kschl =  lv_kschl
                                vkorg =  lwa_item-vkorg
                                vtweg =  lwa_item-vtweg
                                kunag =  lwa_item-kunnr
                                kunwe =  lwa_item-kunwe
                                datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                        BINARY SEARCH.
* If condition record not found, skip it
        IF sy-subrc IS NOT INITIAL .
          lv_commit_fail =  abap_true    .
          lv_skip   = abap_true.
          lwa_bapi_msg-type       = zcacl_message_container=>c_error.
          lwa_bapi_msg-id         = attrc_msgid.
          lwa_bapi_msg-number     = lc_msg_201.
          lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
        ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
          lwa_bapicondct-cond_no =   <lfs_con_945>-knumh.
          lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
          lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      WHEN  lc_946.
        READ TABLE li_con_946 ASSIGNING <lfs_con_946>
                   WITH KEY     kappl =  lc_kappl
                                    kschl =  lv_kschl
                                    vkorg =  lwa_item-vkorg
                                    vtweg =  lwa_item-vtweg
                                    kunag =  lwa_item-kunnr
                                    datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                    datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                                     BINARY SEARCH.
* If condition record not found, skip it
        IF sy-subrc IS NOT INITIAL .
          lv_commit_fail =  abap_true    .
          lv_skip   = abap_true.
          lwa_bapi_msg-type       = zcacl_message_container=>c_error.
          lwa_bapi_msg-id         = attrc_msgid.
          lwa_bapi_msg-number     = lc_msg_202.
          lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
        ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
          lwa_bapicondct-cond_no =   <lfs_con_946>-knumh.
          lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
          lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
        ENDIF. " IF sy-subrc IS NOT INITIAL
*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
      WHEN  lc_914.
        READ TABLE li_con_914 ASSIGNING <lfs_con_914>
                   WITH KEY     kappl =  lc_kappl
                                    kschl =  lv_kschl
                                    vkorg =  lwa_item-vkorg
                                    vtweg =  lwa_item-vtweg
                                    kunwe =  lwa_item-kunwe
                                    datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                    datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                                     BINARY SEARCH.
* If condition record not found, skip it
        IF sy-subrc IS NOT INITIAL .
          lv_commit_fail =  abap_true    .
          lv_skip   = abap_true.
          lwa_bapi_msg-type       = zcacl_message_container=>c_error.
          lwa_bapi_msg-id         = attrc_msgid.
          lwa_bapi_msg-number     = lc_msg_202.
          lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
        ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
          lwa_bapicondct-cond_no =   <lfs_con_914>-knumh.
          lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
          lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
        ENDIF. " IF sy-subrc IS NOT INITIAL
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
      WHEN lc_935 .
        READ TABLE li_con_935 ASSIGNING <lfs_con_935>
                   WITH KEY     kappl =  lc_kappl
                                    kschl =  lv_kschl
                                    vkorg =  lwa_item-vkorg
                                    vtweg =  lwa_item-vtweg
                                    kunag =  lwa_item-kunnr
                                    kunwe =  lwa_item-kunwe
                                    matnr  = lwa_item-matnr
                                    datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                    datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                                     BINARY SEARCH.
* If condition record not found, skip it
        IF sy-subrc IS NOT INITIAL .
          lv_commit_fail          = abap_true    .
          lv_skip                 = abap_true.
          lwa_bapi_msg-type       = zcacl_message_container=>c_error.
          lwa_bapi_msg-id         = attrc_msgid.
          lwa_bapi_msg-number     = lc_msg_203.
          lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
          me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
        ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
          lwa_bapicondct-cond_no =   <lfs_con_935>-knumh.
          lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
          lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      WHEN lc_005 .
* If KBETER is not initial, then it is ZB00
        IF  lv_kbetr  NE '0.00'.
          READ TABLE li_con_005 ASSIGNING <lfs_con_005>
                     WITH KEY         kappl =  lc_kappl
                                      kschl =  lv_kschl
                                      vkorg =  lwa_item-vkorg
                                      vtweg =  lwa_item-vtweg
                                      kunnr =  lwa_item-kunnr
                                      matnr =  lwa_item-matnr
                                      datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                      datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                                       BINARY SEARCH.
* If condition record not found, skip it
          IF sy-subrc IS NOT INITIAL .
            lv_commit_fail =  abap_true    .
            lv_skip   = abap_true.
            lwa_bapi_msg-type       = zcacl_message_container=>c_error.
            lwa_bapi_msg-id         = attrc_msgid.
            lwa_bapi_msg-number     = lc_msg_204.
            lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
            me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
          ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
            lwa_bapicondct-cond_no =   <lfs_con_005>-knumh.
            lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
            lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
          ENDIF. " IF sy-subrc IS NOT INITIAL
* select from ZM01 table
        ELSE. " ELSE -> IF lv_kbetr NE '0 00'
          READ TABLE li_con_005_zm01  ASSIGNING <lfs_con_005>
                     WITH KEY         kappl =  lc_kappl
                                      kschl =  lv_kschl
                                      vkorg =  lwa_item-vkorg
                                      vtweg =  lwa_item-vtweg
                                      kunnr =  lwa_item-kunnr
                                      matnr =  lwa_item-matnr
                                      datbi =  lwa_item-datbi
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*                                      datab =  lwa_item-datab
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
                                       BINARY SEARCH.
* If condition record not found, skip it
          IF sy-subrc IS NOT INITIAL .
            lv_commit_fail =  abap_true    .
            lv_skip   = abap_true.
            lwa_bapi_msg-type       = zcacl_message_container=>c_error.
            lwa_bapi_msg-id         = attrc_msgid.
            lwa_bapi_msg-number     = lc_msg_204.
            lwa_bapi_msg-message_v1 = lwa_bapicondct-varkey.
            me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
          ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
            lwa_bapicondct-cond_no =   <lfs_con_005>-knumh.
            lwa_bapicondhd-cond_no =  lwa_bapicondct-cond_no.
            lwa_bapicondit-cond_no = lwa_bapicondct-cond_no.
          ENDIF. " IF sy-subrc IS NOT INITIAL
        ENDIF . " IF lv_kbetr NE '0 00'
      WHEN  OTHERS.
* Do   nothing
    ENDCASE.
    lwa_bapicondct-operation = lc_del_op.
    lwa_bapicondhd-operation = lc_del_op.
    lwa_bapicondit-operation = lc_del_op.
    lv_physically_del = abap_false.
  ENDIF. " IF lwa_item-loevm_ko IS INITIAL
  lwa_bapicondct-cond_usage = lc_kvewe.
  lwa_bapicondct-applicatio = lc_kappl.
  lwa_bapicondct-cond_type = lv_kschl .
  lwa_bapicondct-valid_to = lwa_item-datbi.
  lwa_bapicondct-valid_from = lwa_item-datab.
  lwa_bapicondhd-cond_usage = lc_kvewe .
  lwa_bapicondhd-applicatio = lc_kappl .
  lwa_bapicondhd-cond_type = lv_kschl .
  lwa_bapicondit-applicatio = lc_kappl.
  lwa_bapicondit-cond_count = lc_kopos.
  lwa_bapicondit-cond_type = lv_kschl.
  lwa_bapicondit-cond_p_unt = lwa_item-kpein.
  lwa_bapicondit-cond_unit = lwa_item-kmein.
  lwa_bapicondit-calctypcon = lc_krech .
  lwa_bapicondit-cond_value = lwa_item-kbetr .
  lwa_bapicondit-condcurr = lwa_item-konwa.

  IF lv_skip NE abap_true.
* Populate Bapi table
    APPEND  lwa_bapicondct  TO li_bapicondct .
    APPEND lwa_bapicondhd TO li_bapicondhd   .
    APPEND lwa_bapicondit TO li_bapicondit   .
    TRY.
        IF lwa_item-loevm_ko IS NOT INITIAL.
* This BAPI has been call inside the loop because we have to catch the condition no upon isert to update the condition text
** init maintenance session
          lwa_task-kvewe = lc_kvewe.
          lwa_task-kappl = lc_kappl.
*  Initialize condition maintenance
          TRY.
              CALL FUNCTION 'COND_MNT_INIT'
                EXPORTING
                  is_task      = lwa_task
                  iv_condtype  = lv_kschl
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

              APPEND lwa_message TO li_messages1.
              CLEAR lwa_message.
          ENDTRY.

          CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
            EXPORTING
              pi_physical_deletion = lv_physically_del
            TABLES
              ti_bapicondct        = li_bapicondct
              ti_bapicondhd        = li_bapicondhd
              ti_bapicondit        = li_bapicondit
              ti_bapicondqs        = li_bapicondqs
              ti_bapicondvs        = li_bapicondvs
              to_bapiret2          = li_bapiret2
              to_bapiknumhs        = li_bapiknumhs
              to_mem_initial       = li_mem_initial
            EXCEPTIONS
              update_error         = 1
              OTHERS               = 2.
          IF sy-subrc EQ 0.
            READ TABLE li_bapiret2  WITH KEY  type  = lc_error TRANSPORTING  NO FIELDS . " Bapiret2 with ke of type
            IF sy-subrc NE 0.
              READ TABLE li_bapiret2  WITH KEY  type  = lc_abort TRANSPORTING  NO FIELDS . " Bapiret2 with ke of type
              IF sy-subrc NE 0.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true.
                TRY.
                    CALL FUNCTION 'COND_MNT_END'
                      EXPORTING
                        iv_handle          = lv_handle
                        iv_ignore_dataloss = abap_true
                      IMPORTING
                        et_messages        = li_messages.
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
                ENDTRY.
              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF sy-subrc NE 0
          ELSE. " ELSE -> IF sy-subrc EQ 0
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF. " IF sy-subrc EQ 0
        ELSE. " ELSE -> IF lwa_item-loevm_ko IS NOT INITIAL
          CLEAR:lwa_price_data.
          REFRESH:li_konh,li_konp.
*--Create object instance for condition utilities
          CREATE OBJECT lr_cond_utils.
          CLEAR:lwa_price_data.
          lwa_price_data-vkorg   = lwa_item-vkorg.
          lwa_price_data-vtweg   = lwa_item-vtweg.
          lwa_price_data-datab   = lwa_item-datab.
          lwa_price_data-datbi   = lwa_item-datbi.
          READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
               WITH KEY criteria =    lc_kschl_zm01
                        active = abap_true.
          IF sy-subrc IS INITIAL.
            IF lv_kschl = <lfs_constants>-sel_low.
* If KBETER is initial ,  then populate ZM01   else ZB00
              IF lv_kbetr = '0.00'.
                READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
               WITH KEY criteria =    lc_kbetr
                        active = abap_true.
                IF sy-subrc IS  INITIAL.
                  lwa_price_data-kbetr   =  <lfs_constants>-sel_low .
                  lwa_price_data-konwa   =  lc_konwa.
                ELSE. " ELSE -> IF sy-subrc IS INITIAL
                  lwa_price_data-kbetr   = lwa_item-kbetr.
                  lwa_price_data-konwa   = lwa_item-konwa.
                ENDIF. " IF sy-subrc IS INITIAL
              ELSE. " ELSE -> IF lv_kbetr = '0 00'
                lwa_price_data-kbetr   = lwa_item-kbetr.
                lwa_price_data-konwa   = lwa_item-konwa.
              ENDIF. " IF lv_kbetr = '0 00'
            ELSE. " ELSE -> IF lv_kschl = <lfs_constants>-sel_low
              lwa_price_data-kbetr   = lwa_item-kbetr.
              lwa_price_data-konwa   = lwa_item-konwa.
            ENDIF      . " IF lv_kschl = <lfs_constants>-sel_low
          ELSE. " ELSE -> IF sy-subrc IS INITIAL
            lwa_price_data-kbetr   = lwa_item-kbetr.
            lwa_price_data-konwa   = lwa_item-konwa.
          ENDIF      . " IF sy-subrc IS INITIAL

          READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
               WITH KEY criteria =    lc_kschl_zf01
                        active = abap_true.
          IF sy-subrc IS INITIAL.
            IF lv_kschl = <lfs_constants>-sel_low.
* If KBETER is initial ,  then populate ZM01   else ZB00
              IF lv_kbetr = '0.00'.
                READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
               WITH KEY criteria =    lc_kbetr
                        active = abap_true.
                IF sy-subrc IS  INITIAL.
                  lwa_price_data-kbetr   =  <lfs_constants>-sel_low .
                  lwa_price_data-konwa   =  lc_konwa.
                ELSE. " ELSE -> IF sy-subrc IS INITIAL
                  lwa_price_data-kbetr   = lwa_item-kbetr.
                  lwa_price_data-konwa   = lwa_item-konwa.
                ENDIF. " IF sy-subrc IS INITIAL
              ELSE. " ELSE -> IF lv_kbetr = '0 00'
                IF lwa_price_data-konwa IS INITIAL.
                  lwa_price_data-kbetr   = lwa_item-kbetr.
                  lwa_price_data-konwa   = lwa_item-konwa.
                ENDIF. " IF lwa_price_data-konwa IS INITIAL
              ENDIF. " IF lv_kbetr = '0 00'
            ELSE. " ELSE -> IF lv_kschl = <lfs_constants>-sel_low
              IF lwa_price_data-konwa IS INITIAL.
                lwa_price_data-kbetr   = lwa_item-kbetr.
                lwa_price_data-konwa   = lwa_item-konwa.
              ENDIF. " IF lwa_price_data-konwa IS INITIAL
            ENDIF      . " IF lv_kschl = <lfs_constants>-sel_low
          ELSE. " ELSE -> IF sy-subrc IS INITIAL
            lwa_price_data-kbetr   = lwa_item-kbetr.
            lwa_price_data-konwa   = lwa_item-konwa.
          ENDIF      . " IF sy-subrc IS INITIAL
          lwa_price_data-kmein   = lwa_item-kmein.
          lwa_price_data-kotabnr = lv_kotabnr.
          lwa_price_data-kpein   = lwa_item-kpein.
          lwa_price_data-kschl   = lv_kschl.
          lwa_price_data-matnr   = lwa_item-matnr.
** init maintenance session
          lwa_task-kvewe = lc_kvewe.
          lwa_task-kappl = lc_kappl.
*  Initialize condition maintenance
          TRY.
              CALL FUNCTION 'COND_MNT_INIT'
                EXPORTING
                  is_task      = lwa_task
                  iv_condtype  = lv_kschl
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
              APPEND lwa_message TO li_messages1.
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
*-Fill the details for condition record header
          lwa_konh-knumh   = lv_knumh.
          lwa_konh-ernam   = sy-uname.
          lwa_konh-erdat   = sy-datlo.
          lwa_konh-kvewe   = lc_kvewe.
          lwa_konh-kotabnr = lv_kotabnr.
          lwa_konh-kappl   = lc_kappl.
          lwa_konh-kschl   = lv_kschl.
          lwa_konh-vakey   = lwa_bapicondhd-varkey.
          lwa_konh-datab   = lwa_price_data-datab.
          lwa_konh-datbi   = lwa_price_data-datbi.
          APPEND lwa_konh TO li_konh.
          CLEAR lwa_konh.
*-Fill the details for condition record item
          lwa_konp-knumh = lv_knumh.
          lwa_konp-kopos = lc_kopos.
          lwa_konp-kschl = lv_kschl.
*--Check the condition type for ZF01
          READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
           WITH KEY criteria =    lc_kschl_zf01
                    active = abap_true.
          IF sy-subrc IS  INITIAL.
            IF lwa_konp-kschl = <lfs_constants>-sel_low.
*--Multiple amount * 10 and currency to space
              lwa_konp-kbetr = lwa_price_data-kbetr * 10.
              lwa_konp-krech = lc_krech_a.
              lwa_konp-konwa = '%'.
            ELSE. " ELSE -> IF lwa_konp-kschl = <lfs_constants>-sel_low
              lwa_konp-kbetr = lwa_price_data-kbetr.
              lwa_konp-krech = lc_krech.
              lwa_konp-konwa = lwa_price_data-konwa.
            ENDIF. " IF lwa_konp-kschl = <lfs_constants>-sel_low
          ENDIF. " IF sy-subrc IS INITIAL
* Populate the ZM01 with default value
          READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
           WITH KEY criteria =    lc_kschl_zm01
                    active = abap_true.
          IF sy-subrc IS  INITIAL.
            IF lwa_konp-kschl = <lfs_constants>-sel_low.
*--Multiple amount * 10 and currency to space
              lwa_konp-kbetr = lwa_price_data-kbetr * 10.
              lwa_konp-krech = lc_krech_a.
              lwa_konp-konwa = '%'.
            ELSE. " ELSE -> IF lwa_konp-kschl = <lfs_constants>-sel_low
              IF lwa_konp-krech IS INITIAL.
                lwa_konp-kbetr = lwa_price_data-kbetr.
                lwa_konp-krech = lc_krech.
                lwa_konp-konwa = lwa_price_data-konwa.
              ENDIF. " IF lwa_konp-krech IS INITIAL
            ENDIF. " IF lwa_konp-kschl = <lfs_constants>-sel_low
          ENDIF. " IF sy-subrc IS INITIAL
          lwa_konp-kappl = lc_kappl.
          lwa_konp-kschl = lv_kschl.
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
              APPEND lwa_message TO li_messages1.
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
              APPEND lwa_message TO li_messages1.
              CLEAR lwa_message.
          ENDTRY.
          APPEND LINES OF li_messages TO li_messages1.
** Insert condition record
          lwa_record-kotabnr = lwa_price_data-kotabnr .
          lwa_record-kschl   = lwa_price_data-kschl   .
          lwa_record-datbi   = lwa_price_data-datbi  .
          lwa_record-datab   = lwa_price_data-datab   .
          lwa_record-vakey   = lwa_bapicondhd-varkey.
          lwa_record-kvewe   = lc_kvewe.
          lwa_record-kappl  = lc_kappl.
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
              APPEND lwa_message TO li_messages.
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
            READ TABLE li_messages1 WITH KEY msgty = lc_error TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0. " Check any errors occured
              READ TABLE li_messages1 WITH KEY msgty =  lc_abort  TRANSPORTING NO FIELDS.
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
                    APPEND lwa_message TO li_messages1.
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
        ENDIF. " IF lwa_item-loevm_ko IS NOT INITIAL
*    If successfully updated,  then  Concition text updated for inserted  condition  record no
        IF sy-subrc EQ  0.
          READ TABLE li_bapiret2  WITH KEY  type  = lc_error TRANSPORTING  NO FIELDS . " Bapiret2 with ke of type
          IF sy-subrc NE 0.

            READ TABLE li_bapiret2  WITH KEY  type  = lc_abort TRANSPORTING  NO FIELDS . " Bapiret2 with ke of type
            IF sy-subrc NE 0.
              IF lwa_item-ztext IS NOT INITIAL   .
                READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                                          WITH KEY criteria =    lc_text_procedure
                                                   active = abap_true.
                IF sy-subrc IS  INITIAL.
                  READ TABLE li_bapiret2  ASSIGNING <lfs_bapiret2>  WITH KEY  type  = lc_success  . " Bapiret2 with ke of type
                  IF sy-subrc EQ 0.
                    IF lwa_item-loevm_ko IS NOT INITIAL.
                      IF <lfs_bapiret2>-message_v3  EQ  lc_op_type OR
                         <lfs_bapiret2>-message_v3  EQ  lc_op_type_u  .
                        CONCATENATE <lfs_bapiret2>-message_v1 <lfs_constants>-sel_low INTO lwa_text_create-fname.
                        lwa_text_create-cond_value = <lfs_bapiret2>-message_v1 .

                      ENDIF. " IF <lfs_bapiret2>-message_v3 EQ lc_op_type OR

                      READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                                                WITH KEY criteria =    lc_id
                                                         active = abap_true.
                      IF sy-subrc IS  INITIAL.

                        lwa_text_create-tdid   = <lfs_constants>-sel_low .
                        lwa_text_create-tdline = lwa_item-ztext.
                        APPEND  lwa_text_create TO li_text_create .

                      ENDIF. " IF sy-subrc IS INITIAL
                    ELSE. " ELSE -> IF lwa_item-loevm_ko IS NOT INITIAL
                      READ TABLE li_record_keys ASSIGNING <lfs_record_key> INDEX 1.
                      IF sy-subrc EQ 0.
                        CONCATENATE <lfs_record_key>-knumh <lfs_constants>-sel_low INTO lwa_text_create-fname.
                        lwa_text_create-cond_value = <lfs_record_key>-knumh.
                      ENDIF. " IF sy-subrc EQ 0

                      READ TABLE  gi_enh_status ASSIGNING <lfs_constants>
                                                WITH KEY criteria =    lc_id
                                                         active = abap_true.
                      IF sy-subrc IS  INITIAL.
                        lwa_text_create-tdid   = <lfs_constants>-sel_low .
                        lwa_text_create-tdline = lwa_item-ztext.
                        APPEND  lwa_text_create TO li_text_create .
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDIF. " IF lwa_item-loevm_ko IS NOT INITIAL
                  ENDIF. " IF sy-subrc EQ 0
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF lwa_item-ztext IS NOT INITIAL
            ELSE. " ELSE -> IF sy-subrc NE 0

              lv_commit_fail =  abap_true    .
              LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>.
                IF <lfs_bapiret2>-type EQ lc_error OR
                   <lfs_bapiret2>-type EQ lc_abort.
                  me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
                ENDIF. " IF <lfs_bapiret2>-type EQ lc_error OR
              ENDLOOP. " LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>
            ENDIF. " IF sy-subrc NE 0
          ELSE. " ELSE -> IF sy-subrc NE 0

            lv_commit_fail =  abap_true    .
            LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>.
              IF <lfs_bapiret2>-type EQ lc_error OR
                <lfs_bapiret2>-type EQ lc_abort.
                me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
              ENDIF. " IF <lfs_bapiret2>-type EQ lc_error OR
            ENDLOOP. " LOOP AT li_bapiret2 ASSIGNING <lfs_bapiret2>
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc EQ 0
      CATCH cx_root INTO lref_oref.
        lv_commit_fail =  abap_true    .
        lv_text                 = lref_oref->get_text( ).
        lwa_bapi_msg-type       = zcacl_message_container=>c_error.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg.
        lwa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
    ENDTRY.
  ENDIF. " IF lv_skip NE abap_true

  CLEAR: lv_skip,
         lwa_bapicondct,
         lwa_bapicondhd ,
         lwa_bapicondit ,
         lwa_text_create.

  CLEAR:   li_bapicondct,
           li_bapicondhd ,
           li_bapicondit,
           li_bapicondqs,
           li_bapicondvs,
           li_bapiret2,
           li_bapiknumhs,
           li_mem_initial.

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
      lv_commit_fail =  abap_true    .
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
      lv_commit_fail =  abap_true    .
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
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    LOOP AT li_text_create  ASSIGNING <lfs_text_create> .
      lwa_line-tdline = <lfs_text_create>-tdline  .
      APPEND  lwa_line TO li_line .
* Create condition text  in condition
      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          fid       = <lfs_text_create>-tdid
          flanguage = sy-langu
          fname     = <lfs_text_create>-fname
          fobject   = lc_object
        TABLES
          flines    = li_line
        EXCEPTIONS
          no_init   = 1
          no_save   = 2
          OTHERS    = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
        lwa_bapi_msg-id         = attrc_msgid.
        lwa_bapi_msg-number     = lc_msg_199.
        lwa_bapi_msg-message_v1 = <lfs_text_create>-cond_value   .
        me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
      ENDIF. " IF sy-subrc <> 0

*To have the system return the message ID after the sender has sent a request message
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
        lv_count = lv_count + 1 .
        lwa_sxmspdata-extr_count =  lv_count. "Default Value - 1
        lwa_sxmspdata-value      =  <lfs_text_create>-cond_value. "Value
        lwa_sxmspdata-method     =  lc_success. "S
        APPEND lwa_sxmspdata TO li_sxmspdata.
        CLEAR lwa_sxmspdata.
* Check EMI activated or not
        READ TABLE  gi_enh_status
                    WITH KEY criteria =  lc_eztrac_gap
                             sel_low  =  'GAP'
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
**Add the error message in the message container
            lwa_bapi_msg-type       = zcacl_message_container=>c_warning.
            lwa_bapi_msg-id         = attrc_msgid.
            lwa_bapi_msg-number     = lc_msg_205.
            lwa_bapi_msg-message_v1 = <lfs_text_create>-cond_value. "Value
            me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_xml_message_id IS NOT INITIAL
      CLEAR: lwa_line,
             li_line,
             li_sxmspdata,
             lwa_sxmspdata.
    ENDLOOP. " LOOP AT li_text_create ASSIGNING <lfs_text_create>
  ELSE. " ELSE -> IF lv_commit_fail NE abap_true
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF. " IF lv_commit_fail NE abap_true
* Prepare FEH error
  IF me->has_error( ) = abap_true.
    me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
    me->feh_prepare( im_input ).
  ENDIF. " IF me->has_error( ) = abap_true
ENDMETHOD.
ENDCLASS.
