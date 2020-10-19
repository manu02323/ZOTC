class ZOTCCL_CPQ_PRICE_COND_LOAD definition
  public
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data GI_ENH_STATUS type ZDEV_TT_ENH_STATUS .
  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .
  data GV_TMP_INPUT type Z01OTC_MT_CPQPRICE .

  methods PROCESS_DATA
    importing
      !IM_INPUT type Z01OTC_DT_CPQPRICE_RECORD .
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
  methods FEH_PREPARE
    importing
      !IM_INPUT type Z01OTC_DT_CPQPRICE_RECORD .
  methods CONSTRUCTOR .
protected section.
private section.

  class-data ATTRV_ECH_ACTION type ref to ZOTCCL_CPQ_PRICE_COND_LOAD .
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG' ##NO_TEXT.
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .
  methods GENERATE_VARKEY
    importing
      !IM_INPUT type Z01OTC_DT_CPQPRICE_RECORD
    exporting
      !EX_VARKEY type BAPICONDCT-VARKEY .
ENDCLASS.



CLASS ZOTCCL_CPQ_PRICE_COND_LOAD IMPLEMENTATION.


  METHOD constructor.
***************************************************************************
* Method     :  CONSTRUCTOR                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    "Check instance of the object
    CHECK attrv_msg_container IS NOT BOUND.
    CREATE OBJECT attrv_msg_container.

  ENDMETHOD.


  METHOD feh_execute.
***************************************************************************
* Method     :  FEH_EXECUTE                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    DATA: lv_raise_exception  TYPE xflag                       VALUE IS INITIAL, "New Input Values
          lr_feh_registration TYPE REF TO cl_feh_registration  VALUE IS INITIAL, "Registration and Restarting of FEH
          lr_cx_system        TYPE REF TO cx_ai_system_fault   VALUE IS INITIAL, "Application Integration: Technical Error
          lv_mtext            TYPE string                      VALUE IS INITIAL, "Text value
          i_bapiret           TYPE bapirettab                  VALUE IS INITIAL. "Table with BAPI Return Information

    FIELD-SYMBOLS  <lfs_feh_data> TYPE zca_feh_data. "FEH Line

    CONSTANTS c_msg_fault   TYPE  classname VALUE 'CX_SAPPLCO_STANDARD_MSG_FAULT'. " Reference type

    IF lines( attrv_feh_data ) > 0.
      IF im_ref_registration IS BOUND.
        CLEAR lv_raise_exception.
        lr_feh_registration = im_ref_registration.
      ELSE. " ELSE -> if im_ref_registration is bound
        lv_raise_exception = abap_true.
        lr_feh_registration = cl_feh_registration=>s_initialize( is_single = space ).
      ENDIF. " if im_ref_registration is bound

      TRY.
**Process all the FEH data
          LOOP AT attrv_feh_data ASSIGNING <lfs_feh_data> .
            CALL METHOD lr_feh_registration->collect
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
            APPEND LINES OF <lfs_feh_data>-all_messages TO i_bapiret.
          ENDLOOP. " loop at attrv_feh_data assigning <lfs_feh_data>
        CATCH cx_ai_system_fault INTO lr_cx_system.
          lv_mtext = lr_cx_system->get_text( ).
          MESSAGE x026(bs_soa_common) WITH lv_mtext. "System error in the ForwardError Handling: &1
      ENDTRY.

      "Free memory
      FREE attrv_feh_data.

**Raise Exception
      IF lv_raise_exception = abap_true.
        "Please raise the same exception in the proxy method definition
        CALL METHOD cl_proxy_fault=>raise(
          EXPORTING
            exception_class_name = c_msg_fault
            bapireturn_tab       = i_bapiret ).

      ENDIF. " if lv_raise_exception = abap_true
    ENDIF. " if lines( attrv_feh_data ) > 0

  ENDMETHOD.


  METHOD feh_prepare.
***************************************************************************
* Method     :  FEH_PREPARE                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

    CONSTANTS: c_one     TYPE ech_dte_objcat VALUE '1',             "Object Category
               c_cpq     TYPE char3          VALUE 'CPQ',          " CPQ of type CHAR3
               c_obj_cpq TYPE z_enhancement  VALUE 'D3_OTC_IDD_0230'. " Obj_ppm of type CHAR13

    DATA: wa_feh_data        TYPE zca_feh_data  VALUE IS INITIAL, "FEH Line
          wa_ech_main_object TYPE ech_str_object  VALUE IS INITIAL, "Object of Business Process
          i_applmsg          TYPE applmsgtab  VALUE IS INITIAL, "Return Table for Messages

** lr_data is used to in reference to proxy, so it can not be avoided
          lr_data            TYPE REF TO data VALUE IS INITIAL, "Class
          lr_dref            TYPE REF TO data,  "  class
          lv_objkey          TYPE ech_dte_objkey  VALUE IS INITIAL, "Object Key
          wa_bapiret         TYPE bapiret2  VALUE IS INITIAL. "Return Parameter

    FIELD-SYMBOLS: <lfs_appl_msg> TYPE applmsg,                     "Return Structure for Messages
                   <lfs_input>    TYPE z01otc_dt_cpqprice_record. " Proxy Structure (generated)

    CONCATENATE c_obj_cpq
                c_cpq
                 INTO lv_objkey SEPARATED BY space.

* The error category should depends on the actually error not below testing category
    wa_feh_data-error_category  = attrv_msg_container->get_err_category( ).
    wa_ech_main_object-objcat   = c_one.
    wa_ech_main_object-objtype  = me->attrv_objtype.
    wa_ech_main_object-objkey   = lv_objkey.
    wa_feh_data-main_object     = wa_ech_main_object.

    CREATE DATA lr_dref TYPE z01otc_dt_cpqprice_record. " Proxy Structure (generated)
    ASSIGN lr_dref->* TO <lfs_input>.

    CHECK <lfs_input> IS ASSIGNED.
    <lfs_input> = im_input.

    GET REFERENCE OF <lfs_input> INTO lr_data.
    IF sy-subrc EQ 0.
      wa_feh_data-single_bo_ref = lr_data.
    ENDIF.

    i_applmsg = attrv_msg_container->get_appl_messages( ).

    LOOP AT i_applmsg ASSIGNING <lfs_appl_msg>.
      wa_bapiret-type        = <lfs_appl_msg>-type.
      wa_bapiret-id          = <lfs_appl_msg>-id.
      wa_bapiret-number      = <lfs_appl_msg>-number.
      wa_bapiret-message     = <lfs_appl_msg>-number.
      wa_bapiret-log_no      = <lfs_appl_msg>-log_no.
      wa_bapiret-log_msg_no  = <lfs_appl_msg>-log_msg_no.
      wa_bapiret-message_v1  = <lfs_appl_msg>-message_v1.
      wa_bapiret-message_v2  = <lfs_appl_msg>-message_v2.
      wa_bapiret-message_v3  = <lfs_appl_msg>-message_v3.
      wa_bapiret-message_v4  = <lfs_appl_msg>-message_v4.
      wa_bapiret-parameter   = <lfs_appl_msg>-parameter.
      wa_bapiret-row         = <lfs_appl_msg>-row.
      wa_bapiret-field       = <lfs_appl_msg>-field.
      wa_bapiret-system      = <lfs_appl_msg>-system.

      APPEND wa_bapiret TO wa_feh_data-all_messages.
      CLEAR wa_bapiret.
    ENDLOOP. " loop at i_applmsg assigning <lfs_appl_msg>

* Get main message from message container
    wa_feh_data-main_message = attrv_msg_container->get_main_error( ).

* To Populate Main message
    READ TABLE wa_feh_data-all_messages INDEX 1 INTO wa_feh_data-main_message.
    IF sy-subrc NE 0.
      CLEAR wa_feh_data-main_message.
    ENDIF. " if sy-subrc ne 0

    APPEND wa_feh_data TO attrv_feh_data.
    CLEAR wa_feh_data.
  ENDMETHOD.


  METHOD generate_varkey.
***************************************************************************
* Method     :  GENERATE_VARKEY                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    CONSTANTS:
      c_004 TYPE kotabnr         VALUE '004',  " Material
      c_005 TYPE kotabnr         VALUE '005',  " Customer/Material
      c_600 TYPE kotabnr         VALUE '600',  " Sold-to/Ship-to/Product Family/Product Line
      c_901 TYPE kotabnr         VALUE '901',  " Sales org./Distr. Chl/Buying Group(Cust.grp 1)/Material
      c_902 TYPE kotabnr         VALUE '902',  " Sales org./Distr. Chl/IDN(Cust.grp 2)/Material
      c_909 TYPE kotabnr         VALUE '909',  " Sales org./Distr. Chl/Customer/Mat. Freight Indcator
      c_925 TYPE kotabnr         VALUE '925',  " Sales org./Distr. Chl/Customer/Ship-to/Matl grp 4
      c_935 TYPE kotabnr         VALUE '935',  " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
      c_936 TYPE kotabnr         VALUE '936',  " Sales org./Distr. Chl/Sold-to pt/Ship-to/Product Class
      c_937 TYPE kotabnr         VALUE '937',  " Sales org./Distr. Chl/Sold-to/Product Class
      c_938 TYPE kotabnr         VALUE '938',  " Sales org./Distr. Chl/Cust.grp.2/Product Class
      c_939 TYPE kotabnr         VALUE '939',  " Sales org./Distr. Chl/Cust.grp 1/Product Class
      c_940 TYPE kotabnr         VALUE '940',  " Sales org./Distr. Chl/Industry/Material
      c_966 TYPE kotabnr         VALUE '966',  " Sales org./Distr. Chl/Sold-to pt/PO type/Material
      c_972 TYPE kotabnr         VALUE '972',  " Sales org./Distr. Chl/Customer/Product Family
      c_973 TYPE kotabnr         VALUE '973',  " Sales org./Distr. Chl/Cust.grp 1/Product Family
      c_974 TYPE kotabnr         VALUE '974',  " Sales org./Distr. Chl/Cust.grp.2/Product Family
      c_984 TYPE kotabnr         VALUE '984',  " SalesDocTy/National Account /Plant/Matl grp 4
      c_985 TYPE kotabnr         VALUE '985',  " Sales org./Distr. Chl/SalesDocTy/National Ac/Matl grp 4
      c_996 TYPE kotabnr         VALUE '996'.  " Sales org./Distr. Chl/Customer/Ship-to/PH4

    "Generate VARKEY based on table key fields
    CASE im_input-kotabnr.
      WHEN c_004. "Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_005. "Customer/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_600. "Sold-to/Ship-to/Product Family/Product Line
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-kunwe
                    im_input-zprodh4
                    im_input-zprodh5
                    INTO ex_varkey.
      WHEN c_901. "Sales org./Distr. Chl/Buying Group(Cust.grp 1)/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr1
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_902. "Sales org./Distr. Chl/IDN(Cust.grp 2)/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr2
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_909. "Sales org./Distr. Chl/Customer/Mat. Freight Indcator
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-zzmvgr4
                    INTO ex_varkey.
      WHEN c_925. "Sales org./Distr. Chl/Customer/Ship-to/Matl grp 4
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-kunwe
                    im_input-zzmvgr4
                    INTO ex_varkey.
      WHEN c_935. "Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunag
                    im_input-kunwe
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_936. "Sales org./Distr. Chl/Sold-to pt/Ship-to/Product Class
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunag
                    im_input-kunwe
                    im_input-kondm
                    INTO ex_varkey.
      WHEN c_937. "Sales org./Distr. Chl/Sold-to/Product Class
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunag
                    im_input-kondm
                    INTO ex_varkey.
      WHEN c_938. "Sales org./Distr. Chl/Cust.grp.2/Product Class
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr2
                    im_input-kondm
                    INTO ex_varkey.
      WHEN c_939. "Sales org./Distr. Chl/Cust.grp 1/Product Class
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr1
                    im_input-kondm
                    INTO ex_varkey.
      WHEN c_940. "Sales org./Distr. Chl/Industry/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-brsch
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_966. "Sales org./Distr. Chl/Sold-to pt/PO type/Material
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunag
                    im_input-zzbsark
                    im_input-matnr
                    INTO ex_varkey.
      WHEN c_972. "Sales org./Distr. Chl/Customer/Product Family
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-zprodh4
                    INTO ex_varkey.
      WHEN c_973. "Sales org./Distr. Chl/Cust.grp 1/Product Family
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr1
                    im_input-zprodh4
                    INTO ex_varkey.
      WHEN c_974. "Sales org./Distr. Chl/Cust.grp.2/Product Family
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-zzkvgr2
                    im_input-zprodh4
                    INTO ex_varkey.
      WHEN c_984. "SalesDocTy/National Account /Plant/Matl grp 4
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-auart_sd
                    im_input-zzkatr7
                    im_input-werks
                    im_input-zzmvgr4
                    INTO ex_varkey.
      WHEN c_985. "Sales org./Distr. Chl/SalesDocTy/National Ac/Matl grp 4
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-auart_sd
                    im_input-zzkatr7
                    im_input-zzmvgr4
                    INTO ex_varkey.
      WHEN c_996. "Sales org./Distr. Chl/Customer/Ship-to/PH4
        CONCATENATE im_input-vkorg
                    im_input-vtweg
                    im_input-kunnr
                    im_input-kunwe
                    im_input-zprodh4
                    INTO ex_varkey.
      WHEN OTHERS .
*        Do nothing
    ENDCASE.
  ENDMETHOD.


  METHOD has_error.
***************************************************************************
* Method     :  HAS_ERROR                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 06-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    re_result = attrv_msg_container->has_error( ).
  ENDMETHOD.


  METHOD if_ech_action~fail.
***************************************************************************
* Method     :  IF_ECH_ACTION~FAIL                                        *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

    CONSTANTS:  c_fail TYPE  bs_soa_siw_dte_proc_context VALUE 'FAIL'. " Processing context of service implementation

    CLEAR e_execution_failed.
    CLEAR e_return_message.

    me->initialize( im_id_processing_context = c_fail ).

**Set the status to failed in FEH
    CALL METHOD cl_feh_registration=>s_fail
      EXPORTING
        i_data             = i_data
      IMPORTING
        e_execution_failed = e_execution_failed
        e_return_message   = e_return_message.

  ENDMETHOD.


  METHOD if_ech_action~finalize_after_retry_error ##NEEDED.
***************************************************************************
* Method     :  IF_ECH_ACTION~FINALIZE_AFTER_RETRY_ERROR                  *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

  ENDMETHOD.


  METHOD if_ech_action~finish.
***************************************************************************
* Method     :  IF_ECH_ACTION~FINISH                                      *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

    CONSTANTS: c_finish TYPE bs_soa_siw_dte_proc_context  VALUE 'FINISH'. " Processing context of service implementation

    CLEAR e_execution_failed.
    CLEAR e_return_message.

    me->initialize( im_id_processing_context = c_finish ).

**Set the status to finish in FEH
    CALL METHOD cl_feh_registration=>s_finish
      EXPORTING
        i_data             = i_data
      IMPORTING
        e_execution_failed = e_execution_failed
        e_return_message   = e_return_message.

  ENDMETHOD.


  method IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR ##NEEDED.
***************************************************************************
* Method     :  IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR                  *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

  endmethod .


  METHOD if_ech_action~retry.
***************************************************************************
* Method     :  IF_ECH_ACTION~RETRY                                       *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

**This method needs to be implemented to trigger the reprocessing of a message.
*The message will be called if Restart in Monitoring and Error Handling is
*clicked or if Repeat in Error  and  Conflict is selected

    DATA: lref_feh_registration TYPE REF TO cl_feh_registration VALUE IS INITIAL,  "Registration and Restarting of FEH
          lx_input              TYPE z01otc_dt_cpqprice_record  VALUE IS INITIAL.

    CONSTANTS: c_retry TYPE bs_soa_siw_dte_proc_context  VALUE 'RETRY'. "Processing context of service implementation

    CLEAR e_execution_failed.
    CLEAR e_return_message.

**Initialize business logic class
    me->initialize( im_id_processing_context = c_retry ).

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

  ENDMETHOD.


  METHOD if_ech_action~s_create.
***************************************************************************
* Method     :  IF_ECH_ACTION~S_CREATE                                    *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 07-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

**This Generate Instance
    IF NOT attrv_ech_action IS BOUND.
      CREATE OBJECT attrv_ech_action.
    ENDIF. " IF NOT attrv_ech_action IS BOUND

    CHECK attrv_ech_action IS BOUND.
    r_action_class = attrv_ech_action. "Class

  ENDMETHOD.


  METHOD initialize.
***************************************************************************
* Method     :  INITIALIZE                                              *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 06-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*

    CONSTANTS : c_retry    TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',   "Processing context of service implementation
                c_fail     TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',    "Processing context of service implementation
                c_finish   TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH',  "Processing context of service implementation
                c_objtype  TYPE ech_dte_objtype             VALUE 'BUS2144', "Object Type
                c_enh_name TYPE z_enhancement   VALUE 'D3_OTC_IDD_0230'.     " Enhancement No.


**Call the refresh method message container class.
    attrv_msg_container->refresh( ).

**me->refresh( ).
    attrv_pro_context = im_id_processing_context.

**Check the Processing Context
    IF attrv_pro_context EQ c_retry OR
       attrv_pro_context EQ c_fail OR
       attrv_pro_context EQ c_finish.
      FREE attrv_feh_data.
    ENDIF. " IF attrv_pro_context EQ lc_retry OR

    attrv_objtype = c_objtype.

    IF gi_enh_status[] IS INITIAL.
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = c_enh_name
        TABLES
          tt_enh_status     = gi_enh_status[].

      IF gi_enh_status[] IS NOT INITIAL.
        DELETE gi_enh_status WHERE active IS INITIAL.
      ENDIF. " IF gi_enh_status[] IS NOT INITIAL
    ENDIF. " IF gi_enh_status[] IS INITIAL

  ENDMETHOD.


  METHOD process_data.
***********************************************************************************
* Method     :  PROCESS_DATA                                                      *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)           *
* DEVELOPER  :  Ramakrishnan Subramaniam                                          *
* OBJECT TYPE:  Interface                                                         *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0230                                                    *
*---------------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ)         *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                                  *
* =========== ========  ==========   =============================================*
* 06-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230           *
*                                   SC Task# SCTASK0836007                        *
*                                   Assumptions that, we are always going         *
*                                   to push data into SAP without any validations *
*                                   N O --- V A L I D A T I O N S I N --- S A P   *
*&--------------------------------------------------------------------------------*
    CONSTANTS:
      c_eztrac_cpq     TYPE z_criteria      VALUE 'EZTRAC_CPQ',               " Enh. Criteria
      c_text_procedure TYPE z_criteria      VALUE 'TEXT_DETERMINE_PROCEDURE', " Enh. Criteria
      c_id             TYPE z_criteria      VALUE 'TEXT_ID',                  " Enh. Criteria
      c_ins_op         TYPE msgfn           VALUE '009',                      " Function
      c_cond_ins       TYPE knumh           VALUE '$000000001',               " Condition record number
      c_error          TYPE char1           VALUE 'E',                        " Error
      c_message        TYPE char24          VALUE 'IF_WSPROTOCOL_MESSAGE_ID', " XI: Message ID
      c_sender         TYPE sxmspid         VALUE 'SENDER',                   " Integration Engine: Pipeline ID
      c_name           TYPE sxms_extr_name  VALUE 'B_DOCU',                   " Extractor Name
      c_success        TYPE char1           VALUE 'S',                        " Success  message
      c_abort          TYPE char1           VALUE 'A',                        " Abort  message
      c_kopos          TYPE kopos           VALUE '01',                       " Sequential number of the condition
      c_krech          TYPE krech           VALUE 'C',                        " Calculation type for condition
      c_object         TYPE tdobject        VALUE 'KONP',                     " Texts: Application Object
      c_activity       TYPE cond_mnt_activity VALUE 'V',                      " Conditions: Maintenance Activity
      c_msg_000        TYPE symsgno         VALUE '000',                      " Message Number
      c_msg_213        TYPE symsgno         VALUE '213',                      " Message Number
      c_msg_214        TYPE symsgno         VALUE '214',                      " Message Number
      c_msg_199        TYPE symsgno         VALUE '199',                      " Message Number
      c_msg_205        TYPE symsgno         VALUE '205'.                      " Message Number

    DATA:
      i_bapicondct         TYPE STANDARD TABLE OF bapicondct ##NEEDED,      " BAPI struct. for condition tables (corresponds to COND_RECS)
      i_bapicondhd         TYPE STANDARD TABLE OF bapicondhd ##NEEDED,      " BAPI Structure of KONH with English Field Names
      i_bapicondit         TYPE STANDARD TABLE OF bapicondit ##NEEDED,      " BAPI Structure of KONP with English Field Names
      i_bapiret2           TYPE STANDARD TABLE OF bapiret2,        " Return Parameter

      wa_bapicondct        TYPE bapicondct,                        " BAPI struct. for condition tables (corresponds to COND_RECS)
      wa_bapicondhd        TYPE bapicondhd,                        " BAPI Structure of KONH with English Field Names
      wa_bapicondit        TYPE bapicondit,                        " BAPI Structure of KONP with English Field Names
      wa_bapiret2          TYPE bapiret2,                          " Return Parameter
      wa_text_create       TYPE ty_text_create,
      wa_line              TYPE tline,                             " SAPscript: Text Lines

      i_text_create        TYPE ty_text_create_t,
      i_line               TYPE STANDARD TABLE OF tline ,          " SAPscript: Text Lines
      lv_count             TYPE i,                                 " Count
      lv_date_ab           TYPE datum,                             " Date
      lv_date_bi           TYPE datum,                             " Date
      lv_kschl             TYPE kschl,                             " Condition Type
      lv_kotabnr           TYPE kotabnr,                          " Condition table

* FEH related  declaration
      lr_cx_root           TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
      lr_server_cntxt      TYPE REF TO if_ws_server_context         VALUE IS INITIAL, "Proxy Server Context
      lr_wsprotocol_msg_id TYPE REF TO if_wsprotocol_message_id     VALUE IS INITIAL, "XI and WS: Read Message ID
      lr_wsp_protocol      TYPE REF TO if_wsprotocol                VALUE IS INITIAL, "ABAP Proxies: Available Protocols
      lr_cx_root1          TYPE REF TO cx_root                      VALUE IS INITIAL, "Abstract Superclass for All Global Exceptions
      i_sxmspdata          TYPE STANDARD TABLE OF sxmspdata         INITIAL SIZE 0,   "Archive for Message Extract
      wa_sxmspdata         TYPE sxmspdata                           VALUE IS INITIAL, "Archive for Message Extract
      wa_bapi_msg          TYPE bapiret2                            VALUE IS INITIAL, "Return Parameter
      lv_protocol_name     TYPE string                              VALUE IS INITIAL, "Protocol Name
      lv_xml_message_id    TYPE sxmsmguid                           VALUE IS INITIAL, "XI: Message ID
      lv_text              TYPE string                              VALUE IS INITIAL, "String
      i_konh               TYPE TABLE OF konh,                                        " Conditions (Header)
      i_konp               TYPE TABLE OF konp,                                        " Conditions (Item)
      wa_konh              TYPE konh,                                                 " Conditions (Header)
      wa_konp              TYPE konp,                                                 " Conditions (Item)
      wa_task              TYPE vkon_task_key,                                        " Admin. and Appl. (Task) of Condition Technique
      i_messages           TYPE cond_mnt_message_t,
      i_messages1          TYPE cond_mnt_message_t,
      wa_message           TYPE cond_mnt_message,                                     " Condition Maintenance: Message Structure
      lv_subrc             TYPE cond_mnt_result ##NEEDED,                             " Result of Condition Maintenance
      lv_handle            TYPE sytabix,                                              " Index of Internal Tables
      i_selection          TYPE cl_cond_tab_sel=>cond_rngs_t ##NEEDED,
      lv_knumh             TYPE konh-knumh VALUE '$$00000001',
      wa_record            TYPE cond_mnt_record_data,                                 " Condition Maintenance: Condition Record (Key and Data)
      lv_recno             TYPE syloopc ##NEEDED,                                     " Visible Lines of a Step Loop
      i_record_keys        TYPE cond_mnt_record_key_t,
      wa_record_key        TYPE cond_mnt_record_key ##NEEDED,                         " Condition Maintenance: ID and Key of a Condition Record
      lr_cond_utils        TYPE REF TO cl_cond_mnt_util_a.                            " Utilities for Price Maintenance

* Field Symbols
    FIELD-SYMBOLS  :
      <lfs_enh_status>  TYPE zdev_enh_status,                   " Enhancement Status
      <lfs_bapiret2>    TYPE bapiret2,                        " Return Parameter
      <lfs_text_create> TYPE ty_text_create,
      <lfs_record_key>  TYPE cond_mnt_record_key.              " Condition Maintenance: ID and Key of a Condition Record

    TRY.
**Initialize FEH message container
        me->initialize( ).
      CATCH cx_root INTO lr_cx_root.
        lv_text                 = lr_cx_root->get_text( ).
        wa_bapi_msg-type       = zcacl_message_container=>c_error.
        wa_bapi_msg-id         = attrc_msgid.
        wa_bapi_msg-number     = c_msg_000.
        wa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
    ENDTRY.

    lv_kschl = im_input-kschl.   " Condition Type
    lv_kotabnr = im_input-kotabnr. " Condition table

* Validation of To date
    lv_date_bi = im_input-datbi .
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_date_bi
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      wa_bapi_msg-type       = zcacl_message_container=>c_error.
      wa_bapi_msg-id         = attrc_msgid.
      wa_bapi_msg-number     = c_msg_213.
      wa_bapi_msg-message_v1 = lv_date_bi.
      me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
      CLEAR wa_bapi_msg.
    ENDIF. " if sy-subrc <> 0

* Validation of From Date
    lv_date_ab = im_input-datab .
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_date_ab
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      wa_bapi_msg-type       = zcacl_message_container=>c_error.
      wa_bapi_msg-id         = attrc_msgid.
      wa_bapi_msg-number     = c_msg_214.
      wa_bapi_msg-message_v1 = lv_date_ab.
      me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
      CLEAR wa_bapi_msg.
    ENDIF. " if sy-subrc <> 0

* Populate the Condition table
    wa_bapicondct-table_no = im_input-kotabnr .
    wa_bapicondhd-table_no = im_input-kotabnr.

    "Generate VARKEY based on table key fields
    CALL METHOD me->generate_varkey
      EXPORTING
        im_input  = im_input
      IMPORTING
        ex_varkey = wa_bapicondct-varkey.
    wa_bapicondhd-varkey = wa_bapicondct-varkey.


* Always Insert the data into SAP from Interface
* Fill BAPI Structures
    wa_bapicondct-operation = c_ins_op.
    wa_bapicondct-cond_no =  c_cond_ins.

    wa_bapicondhd-operation = c_ins_op.
    wa_bapicondhd-cond_no = c_cond_ins.
    wa_bapicondhd-created_by = sy-uname.
    wa_bapicondhd-creat_date = sy-datum.
    wa_bapicondhd-valid_from = lv_date_ab.
    wa_bapicondhd-valid_to = lv_date_bi.

    wa_bapicondit-operation = c_ins_op.
    wa_bapicondit-cond_no = c_cond_ins.
    wa_bapicondit-cond_count = c_kopos.

    wa_bapicondct-cond_usage = im_input-kvewe.
    wa_bapicondct-applicatio = im_input-kappl.
    wa_bapicondct-cond_type = im_input-kschl.
    wa_bapicondct-valid_to = lv_date_bi.
    wa_bapicondct-valid_from = lv_date_ab.

    wa_bapicondhd-cond_usage = im_input-kvewe.
    wa_bapicondhd-applicatio = im_input-kappl.
    wa_bapicondhd-cond_type = im_input-kschl.

    wa_bapicondit-applicatio = im_input-kappl.
    wa_bapicondit-cond_count = c_kopos.
    wa_bapicondit-cond_type = im_input-kschl.
    wa_bapicondit-cond_p_unt = im_input-kpein.
    wa_bapicondit-cond_unit = im_input-kmein.
    wa_bapicondit-calctypcon = c_krech . "C
    wa_bapicondit-cond_value = im_input-kbetr * 10 .
    wa_bapicondit-condcurr = im_input-konwa.

* Populate Bapi table
    APPEND wa_bapicondct TO i_bapicondct.
    APPEND wa_bapicondhd TO i_bapicondhd.
    APPEND wa_bapicondit TO i_bapicondit.

    TRY.
*--Create object instance for condition utilities
        CREATE OBJECT lr_cond_utils.

** init maintenance session
        wa_task-kvewe = im_input-kvewe.
        wa_task-kappl = im_input-kappl.

*  Initialize condition maintenance
        TRY.
            CALL FUNCTION 'COND_MNT_INIT'
              EXPORTING
                is_task      = wa_task
                iv_condtype  = lv_kschl
                iv_condtable = lv_kotabnr
                iv_activity  = c_activity
              IMPORTING
                ev_handle    = lv_handle
                et_selection = i_selection.
          CATCH cx_cond_mnt_session.
            wa_message-msgty = sy-msgty  .
            wa_message-msgid = sy-msgid   .
            wa_message-msgno = sy-msgno  .
            wa_message-msgv1 = sy-msgv1 .
            wa_message-msgv2 = sy-msgv2 .
            wa_message-msgv3 = sy-msgv3 .
            wa_message-msgv4 = sy-msgv4 .
            APPEND wa_message TO i_messages1.
            CLEAR wa_message.
        ENDTRY.

*-Fill the details for condition record header
        wa_konh-knumh   = lv_knumh.
        wa_konh-ernam   = sy-uname.
        wa_konh-erdat   = sy-datum.
        wa_konh-kvewe   = im_input-kvewe.
        wa_konh-kotabnr = im_input-kotabnr.
        wa_konh-kappl   = im_input-kappl.
        wa_konh-kschl   = im_input-kschl.
        wa_konh-vakey   = wa_bapicondhd-varkey.
        wa_konh-datab   = lv_date_ab.
        wa_konh-datbi   = lv_date_bi.
        APPEND wa_konh TO i_konh.

*-Fill the details for condition record item
        wa_konp-knumh = lv_knumh.
        wa_konp-kopos = c_kopos.
        wa_konp-kschl = im_input-kschl.
        wa_konp-kbetr = im_input-kbetr * 10.
        wa_konp-krech = c_krech.
        wa_konp-konwa = im_input-konwa.
        wa_konp-kappl = im_input-kappl.
        wa_konp-kschl = im_input-kschl.
        wa_konp-kpein = im_input-kpein.
        wa_konp-kmein = im_input-kmein.
        wa_konp-kunnr = im_input-kunnr.
        APPEND wa_konp TO i_konp.

        wa_record-kotabnr = im_input-kotabnr.
        wa_record-kschl   = im_input-kschl.
        wa_record-datbi   = lv_date_bi.
        wa_record-datab   = lv_date_ab.

        TRY.
            CALL METHOD lr_cond_utils->pack_datapart
              EXPORTING
                it_konh = i_konh
                it_konp = i_konp
              RECEIVING
                result  = wa_record-datapart.
          CATCH cx_cond_datacontainer .
            wa_message-msgty = sy-msgty  .
            wa_message-msgid = sy-msgid   .
            wa_message-msgno = sy-msgno  .
            wa_message-msgv1 = sy-msgv1 .
            wa_message-msgv2 = sy-msgv2 .
            wa_message-msgv3 = sy-msgv3 .
            wa_message-msgv4 = sy-msgv4 .
            APPEND wa_message TO i_messages1.
            CLEAR wa_message.
        ENDTRY.

** start maintenance (create mode -> select records)
        TRY.
            CALL FUNCTION 'COND_MNT_START'
              EXPORTING
                iv_handle      = lv_handle
                iv_seldate     = sy-datum
                iv_vakey       = wa_bapicondhd-varkey
              IMPORTING
                ev_subrc       = lv_subrc
                et_messages    = i_messages
                ev_recno       = lv_recno
                et_record_keys = i_record_keys.
          CATCH cx_cond_mnt_session.
            wa_message-msgty = sy-msgty  .
            wa_message-msgid = sy-msgid   .
            wa_message-msgno = sy-msgno  .
            wa_message-msgv1 = sy-msgv1 .
            wa_message-msgv2 = sy-msgv2 .
            wa_message-msgv3 = sy-msgv3 .
            wa_message-msgv4 = sy-msgv4 .
            APPEND wa_message TO i_messages1.
            CLEAR wa_message.
        ENDTRY.
        APPEND LINES OF i_messages TO i_messages1.

** Insert condition record
        wa_record-kotabnr = im_input-kotabnr.
        wa_record-kschl   = im_input-kschl.
        wa_record-datbi   = lv_date_bi.
        wa_record-datab   = lv_date_ab.
        wa_record-vakey   = wa_bapicondhd-varkey.
        wa_record-kvewe   = im_input-kvewe.
        wa_record-kappl   = im_input-kappl.
        TRY.
            CALL FUNCTION 'COND_MNT_RECORD_PUT'
              EXPORTING
                iv_handle        = lv_handle
                iv_allow_overlap = abap_true
                record_data      = wa_record
              IMPORTING
                ev_rec_id        = wa_record_key-record_id
                ev_subrc         = lv_subrc
                et_messages      = i_messages.
          CATCH cx_cond_mnt_session.
            wa_message-msgty = sy-msgty  .
            wa_message-msgid = sy-msgid   .
            wa_message-msgno = sy-msgno  .
            wa_message-msgv1 = sy-msgv1 .
            wa_message-msgv2 = sy-msgv2 .
            wa_message-msgv3 = sy-msgv3 .
            wa_message-msgv4 = sy-msgv4 .
            APPEND wa_message TO i_messages.
            CLEAR wa_message.
          CATCH cx_cond_mnt_record.
            wa_message-msgty = sy-msgty  .
            wa_message-msgid = sy-msgid   .
            wa_message-msgno = sy-msgno  .
            wa_message-msgv1 = sy-msgv1 .
            wa_message-msgv2 = sy-msgv2 .
            wa_message-msgv3 = sy-msgv3 .
            wa_message-msgv4 = sy-msgv4 .
            APPEND wa_message TO i_messages1.
            CLEAR wa_message.
        ENDTRY.
        APPEND LINES OF i_messages TO i_messages1.

** Save condition record
        READ TABLE i_messages1 WITH KEY msgty = c_error TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0. " Check any errors occured
          READ TABLE i_messages1 WITH KEY msgty =  c_abort  TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0. " Check any abend message issued
            TRY.
                CALL FUNCTION 'COND_MNT_SAVE'
                  EXPORTING
                    iv_handle      = lv_handle
                  IMPORTING
                    et_record_keys = i_record_keys
                    et_messages    = i_messages.

              CATCH cx_cond_mnt_session.
                wa_message-msgty = sy-msgty.
                wa_message-msgid = sy-msgid.
                wa_message-msgno = sy-msgno.
                wa_message-msgv1 = sy-msgv1.
                wa_message-msgv2 = sy-msgv2.
                wa_message-msgv3 = sy-msgv3.
                wa_message-msgv4 = sy-msgv4.
                APPEND wa_message TO i_messages1.
                CLEAR wa_message.
            ENDTRY.
            WAIT UP TO 1 SECONDS.
            APPEND LINES OF i_messages TO i_messages1.
          ENDIF. " if sy-subrc <> 0
        ENDIF. " if sy-subrc <> 0

        TRY.
            CALL FUNCTION 'COND_MNT_END'
              EXPORTING
                iv_handle          = lv_handle
                iv_ignore_dataloss = abap_true
              IMPORTING
                et_messages        = i_messages.
          CATCH cx_cond_mnt_session ##NO_HANDLER.
        ENDTRY.
        APPEND LINES OF i_messages TO i_messages1.

        LOOP AT i_messages1 INTO wa_message.
          wa_bapiret2-type       = wa_message-msgty.
          wa_bapiret2-id         = wa_message-msgid.
          wa_bapiret2-number     = wa_message-msgno.
          wa_bapiret2-message_v1 = wa_message-msgv1.
          wa_bapiret2-message_v2 = wa_message-msgv2.
          wa_bapiret2-message_v2 = wa_message-msgv2.
          wa_bapiret2-message_v2 = wa_message-msgv2.
          APPEND wa_bapiret2 TO i_bapiret2.
          CLEAR wa_bapiret2.
        ENDLOOP. " loop at li_messages1 into lwa_message

* If any error occured, no record will be updated. It can be update from FEH reprocess .
* If no error occued,  all record will be created .
        READ TABLE i_messages1 WITH KEY msgty = c_error TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0. "If no error message, call the DB COMMIT.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
        ENDIF.

*    if successfully updated,  then  condition text to be updated for inserted condition  record no
        READ TABLE i_bapiret2 WITH KEY type  = c_error TRANSPORTING  NO FIELDS.
        IF sy-subrc NE 0.
          READ TABLE i_bapiret2  WITH KEY type  = c_abort TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            IF im_input-ztext IS NOT INITIAL   .
              READ TABLE  gi_enh_status ASSIGNING <lfs_enh_status>
                                        WITH KEY criteria = c_text_procedure
                                                 active = abap_true.
              IF sy-subrc IS  INITIAL.
                READ TABLE i_bapiret2  ASSIGNING <lfs_bapiret2>  WITH KEY  type  = c_success.
                IF sy-subrc EQ 0.
                  IF im_input-loevm_ko IS NOT INITIAL.
                  ELSE.
                    READ TABLE i_record_keys ASSIGNING <lfs_record_key> INDEX 1.
                    IF sy-subrc EQ 0.
                      CONCATENATE <lfs_record_key>-knumh <lfs_enh_status>-sel_low INTO wa_text_create-fname.
                      wa_text_create-cond_value = <lfs_record_key>-knumh.
                    ENDIF. " if sy-subrc eq 0

                    READ TABLE  gi_enh_status ASSIGNING <lfs_enh_status>
                                              WITH KEY criteria = c_id
                                                       active = abap_true.
                    IF sy-subrc IS  INITIAL.
                      wa_text_create-tdid   = <lfs_enh_status>-sel_low .
                      wa_text_create-tdline = im_input-ztext.
                      APPEND  wa_text_create TO i_text_create .
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            LOOP AT i_bapiret2 ASSIGNING <lfs_bapiret2>.
              IF <lfs_bapiret2>-type EQ c_error OR
                 <lfs_bapiret2>-type EQ c_abort.
                me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          LOOP AT i_bapiret2 ASSIGNING <lfs_bapiret2>.
            IF <lfs_bapiret2>-type EQ c_error OR
              <lfs_bapiret2>-type EQ c_abort.
              me->attrv_msg_container->add_bapi_message( <lfs_bapiret2> ).
            ENDIF.
          ENDLOOP.
        ENDIF.
      CATCH cx_root INTO lr_cx_root.
        lv_text                 = lr_cx_root->get_text( ).
        wa_bapi_msg-type       = zcacl_message_container=>c_error.
        wa_bapi_msg-id         = attrc_msgid.
        wa_bapi_msg-number     = c_msg_000.
        wa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
    ENDTRY.

    "Update Text, if XML has data
    LOOP AT i_text_create  ASSIGNING <lfs_text_create> .
      wa_line-tdline = <lfs_text_create>-tdline  .
      APPEND  wa_line TO i_line .
* Create condition text  in condition
      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          fid       = <lfs_text_create>-tdid
          flanguage = sy-langu
          fname     = <lfs_text_create>-fname
          fobject   = c_object
        TABLES
          flines    = i_line
        EXCEPTIONS
          no_init   = 1
          no_save   = 2
          OTHERS    = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        wa_bapi_msg-type       = zcacl_message_container=>c_warning.
        wa_bapi_msg-id         = attrc_msgid.
        wa_bapi_msg-number     = c_msg_199.
        wa_bapi_msg-message_v1 = <lfs_text_create>-cond_value   .
        me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
      ENDIF. " if sy-subrc <> 0
      CLEAR: wa_line,i_line.
    ENDLOOP. " loop at li_text_create assigning <lfs_text_create>

**If the Input data is updated successsfully then the link between the message processing and the
*buisness document is created.
    TRY .
        lv_protocol_name = c_message.
**Class cl_proxy_access : To access ABAP proxy runtime objects without using a proxy instance
        CALL METHOD cl_proxy_access=>get_server_context "Server Context
          RECEIVING
            server_context = lr_server_cntxt.         "Server Context
**Method get_protocol :TO access the protocol class.
        CALL METHOD lr_server_cntxt->get_protocol
          EXPORTING
            protocol_name = lv_protocol_name "Protocol Name
          RECEIVING
            protocol      = lr_wsp_protocol.   "Returns the Protocol Class
      CATCH cx_ai_system_fault INTO lr_cx_root.
        lv_text                = lr_cx_root->get_text( ).
        wa_bapi_msg-type       = zcacl_message_container=>c_error.
        wa_bapi_msg-id         = attrc_msgid.
        wa_bapi_msg-number     = c_msg_000.
        wa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
    ENDTRY.

**Get a protocol instance for the protocol IF_WSPROTOCOL_MESSAGE_ID.
    TRY.
        lr_wsprotocol_msg_id ?= lr_wsp_protocol.
      CATCH cx_root INTO lr_cx_root.
        lv_text                 = lr_cx_root->get_text( ).
        wa_bapi_msg-type       = zcacl_message_container=>c_error.
        wa_bapi_msg-id         = attrc_msgid.
        wa_bapi_msg-number     = c_msg_000.
        wa_bapi_msg-message_v1 = lv_text.
        me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
    ENDTRY.

*To have the system return the message ID after the sender has sent a request message
*or the receiver has received a request message, use the method GET_MESSAGE_ID of this instance.
*This returns the ID using the parameter MESSAGE_ID of the type SXMSGUID.
    IF lr_cx_root1 IS NOT BOUND.
      lv_xml_message_id = lr_wsprotocol_msg_id->get_message_id( ). "XML-message ID determination
    ENDIF. " if lref_cx_root is not bound

    "Read the condition record no...
    IF <lfs_record_key> IS NOT ASSIGNED.
      READ TABLE i_record_keys ASSIGNING <lfs_record_key> INDEX 1.
    ENDIF. " if <lfs_record_key> IS NOT ASSIGNED.

    IF lv_xml_message_id IS NOT INITIAL.
**If the data is processed successfully but the file name is blank in Input data then the processing stops
      wa_sxmspdata-msgguid    =  lv_xml_message_id. "PI Message ID
      wa_sxmspdata-pid        =  c_sender. "Default Value - Sender
      wa_sxmspdata-name       =  c_name. "Buisness Document ( B_DOCU )
**The reason 1 is directly passed and not as constant because in SLIN the warning is coming as
**Text literal '1' must be converted to the numeric literal 1
*It is more efficient to enter the numeric literal 1 directly,
      lv_count = lv_count + 1 .
      wa_sxmspdata-extr_count =  lv_count. "Default Value - 1
      IF <lfs_record_key> IS ASSIGNED.
        wa_sxmspdata-value      =  <lfs_record_key>-knumh. "Value
      ELSE.
        wa_sxmspdata-value      = ''.
      ENDIF.
      wa_sxmspdata-method     =  c_success. "S
      APPEND wa_sxmspdata TO i_sxmspdata.
      CLEAR wa_sxmspdata.
* Check EMI activated or not
      READ TABLE  gi_enh_status
                  WITH KEY criteria =  c_eztrac_cpq
                           sel_low  =  'CPQ'
                           active = abap_true
                           TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
*FM ZDEV_UPDATE_SXMSPDATA: To link message processing with the buisness document created
*After the link is set up succesfully with this FM , the table SXMSPDATA is updated
*with the details.
        CALL FUNCTION 'ZDEV_UPDATE_SXMSPDATA'
          EXPORTING
            im_t_sxmspdata   = i_sxmspdata "Archive for Message Extract
          EXCEPTIONS
            record_locked    = 1
            data_not_updated = 2
            OTHERS           = 3.

        IF sy-subrc <> 0.
**Add the error message in the message container
          wa_bapi_msg-type       = zcacl_message_container=>c_warning.
          wa_bapi_msg-id         = attrc_msgid.
          wa_bapi_msg-number     = c_msg_205.
          wa_bapi_msg-message_v1 = <lfs_record_key>-knumh. "Value
          me->attrv_msg_container->add_bapi_message( wa_bapi_msg ).
        ENDIF. " if sy-subrc <> 0
      ENDIF. " if sy-subrc eq 0
    ENDIF. " if lv_xml_message_id is not initial

* Prepare FEH error
    IF me->has_error( ) = abap_true.
      me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
      me->feh_prepare( im_input ).
    ENDIF. " if me->has_error( ) = abap_true

  ENDMETHOD.
ENDCLASS.
