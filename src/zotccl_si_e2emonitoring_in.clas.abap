class ZOTCCL_SI_E2EMONITORING_IN definition
  public
  create public .

public section.
*"* public components of class ZOTCCL_SI_E2EMONITORING_IN
*"* do not include other source files here!!!

  interfaces ZOTCII_SI_E2EMONITORING_IN .

  types:
    TY_T_BAPIRET2            TYPE STANDARD TABLE OF BAPIRET2 .

  methods METH_I_P_APPLOG
    importing
      !IM_I_BAPIRET2 type TY_T_BAPIRET2 .
protected section.
*"* protected components of class ZOTCCL_SI_E2EMONITORING_IN
*"* do not include other source files here!!!
private section.
*"* private components of class ZOTCCL_SI_E2EMONITORING_IN
*"* do not include other source files here!!!

  data OREF type ref to CX_ROOT .
  data OREF_TXT type STRING .
  data C_E type C value 'E'. "#EC NOTEXT .
  data C_025 type CHAR3 value '025'. "#EC NOTEXT .
  data C_030 type CHAR3 value '030'. "#EC NOTEXT .
  data C_ZOTC_MSG type CHAR8 value 'ZOTC_MSG'. "#EC NOTEXT .
ENDCLASS.



CLASS ZOTCCL_SI_E2EMONITORING_IN IMPLEMENTATION.


method meth_i_p_applog.
* Purpose of this method is to create app log for messages ( success or error) during
* creation of application log. All messages are logged under Object ZOTCLOG and subobject
* ZOTCIDD0085.

*local data decleration
  data : lwa_s_log       type bal_s_log,
         lwa_s_msg       type bal_s_msg,
         li_log_handle   type bal_t_logh,
         lv_s_balloghndl type balloghndl,
         lwa_bapiret2  type bapiret2.

*local constants
  constants : lc_zotcidd0085_e2emoni type bal_s_log-subobject value 'ZOTCIDD0085',
              lc_zotclog             type bal_s_log-object    value 'ZOTCLOG',
              lc_high                type bal_s_msg-probclass value '1',
              lc_e                   type symsgty             value 'E'.

  try.
*populate log parameters
      clear lwa_s_log.
      lwa_s_log-object    = lc_zotclog.
      lwa_s_log-subobject = lc_zotcidd0085_e2emoni.
      lwa_s_log-aluser    = sy-uname.
      lwa_s_log-alprog    = sy-repid.

*Fm to create application log handle
      clear lv_s_balloghndl.
      call function 'BAL_LOG_CREATE'
        exporting
          i_s_log      = lwa_s_log
        importing
          e_log_handle = lv_s_balloghndl
        exceptions
          others       = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

      loop at im_i_bapiret2 into lwa_bapiret2.
*populate messages for the app log
        clear lwa_s_msg.
        lwa_s_msg-msgty     = lwa_bapiret2-type.
        lwa_s_msg-msgid     = lwa_bapiret2-id.
        lwa_s_msg-msgno     = lwa_bapiret2-number.
        lwa_s_msg-msgv1     = lwa_bapiret2-message_v1.
        lwa_s_msg-msgv2     = lwa_bapiret2-message_v2.
        lwa_s_msg-msgv3     = lwa_bapiret2-message_v3.
        lwa_s_msg-msgv4     = lwa_bapiret2-message_v4.
        if lwa_s_msg-msgty = lc_e.
          lwa_s_msg-probclass = lc_high.
        endif.
*Add messages to the app log handle
        call function 'BAL_LOG_MSG_ADD'
          exporting
            i_log_handle  = lv_s_balloghndl
            i_s_msg       = lwa_s_msg
          exceptions
            log_not_found = 0
            others        = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endloop.

*Save application log
      refresh li_log_handle[].
      append lv_s_balloghndl to li_log_handle.
      call function 'BAL_DB_SAVE'
        exporting
          i_t_log_handle   = li_log_handle
        exceptions
          log_not_found    = 1
          save_not_allowed = 2
          numbering_error  = 3
          others           = 4.
*Catch exception if any
    catch cx_root into oref.
      oref_txt = oref->get_text( ).
  endtry.

endmethod.


method zotcii_si_e2emonitoring_in~si_e2emonitoring_in.
*** **** INSERT IMPLEMENTATION HERE **** ***
************************************************************************
* CLASS      :  ZOTCCL_SI_E2EMONITORING_IN                             *
* METHOD     :  SI_E2EMONITORING_IN                                    *
* TITLE      :  OTC_IDD_0085 - E2E monitoring for outbound message     *
* DEVELOPER  :  Soham Ghosh                                            *
* OBJECT TYPE:  Inbound ABAP Proxy                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0085                                           *
*----------------------------------------------------------------------*
* DESCRIPTION: This method is called from SAP PI to update idoc status *
*              through Inbound ABAP Proxy                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-Spe-2012 SGHOSH              INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

* Local data declaration.
  constants: c_41 type edi_status value '41',
             c_03 type edi_status value '03'.

*        Idoc number and status from input
  types: begin of lty_idocno,
          docnum  type edi_docnum, "IDoc number
          status  type edi_status, "Status of IDoc
         end of lty_idocno.

* Local Field Symbol
  field-symbols: <lfs_input>  like line of input-data_area,
                 <lfs_idocno> type lty_idocno.

* Local Internal Tables
  data: li_idocno  type standard table of lty_idocno,
        li_edidc   type standard table of lty_idocno,
        li_status  type standard table of bdidocstat,
        li_return2 type standard table of bapiret2 initial size 0.

* Local work area
  data: lwa_idocno  type lty_idocno,
        lwa_edidc   type lty_idocno,
        lwa_status  type bdidocstat,
        lwa_return2 type bapiret2.

* Storing the incoming Idoc number & their status into LI_IDOCNO
  loop at input-data_area assigning <lfs_input>.

*   Populating the idoc number table
    lwa_idocno-docnum = <lfs_input>-bodid.
    lwa_idocno-status = <lfs_input>-bodstatus_code.
    append lwa_idocno to li_idocno.
    clear lwa_idocno.
  endloop.

* Checking the idoc number and its final status from EDIDC
  if li_idocno is not initial.
* Retriving Idoc number and current status of the idocs
    select docnum   "IDoc number
           status   "Status of IDoc
      from edidc
      into table li_edidc
      for all entries in li_idocno
      where docnum = li_idocno-docnum.
    if sy-subrc is initial.
      sort li_edidc by docnum.
    endif.

*   Checking each and every idoc from input file
    loop at li_idocno assigning <lfs_idocno>.
*     Checking if the idoc number exists
      read table li_edidc into lwa_edidc
      with key docnum = <lfs_idocno>-docnum
      binary search.
*     If IDoc number exists, then checking for current status
      if sy-subrc is initial.
*       If Status = 03 - then update the status.
        case lwa_edidc-status.
          when c_41.
*           Do Nothing, just skip the record.
          when c_03.
*           Update the Idoc status to 41

*           Populate the status of IDocs
            refresh li_status.
            lwa_status-docnum = <lfs_idocno>-docnum.
            lwa_status-status = c_41.   "Status = 41
            append lwa_status to li_status.
            clear lwa_status.

*           Updating the Status
            call function 'IDOC_STATUS_WRITE_TO_DATABASE'
              exporting
                idoc_number               = <lfs_idocno>-docnum
              tables
                idoc_status               = li_status
              exceptions
                idoc_foreign_lock         = 1
                idoc_not_found            = 2
                idoc_status_records_empty = 3
                idoc_status_invalid       = 4
                db_error                  = 5
                others                    = 6.
            if sy-subrc is not initial.
              clear lwa_return2.
              lwa_return2-type       = sy-msgty.
              lwa_return2-id         = sy-msgid.
              lwa_return2-number     = sy-msgno.
              lwa_return2-message_v1 = sy-msgv1.
              lwa_return2-message_v2 = sy-msgv2.
              lwa_return2-message_v3 = sy-msgv3.
              lwa_return2-message_v4 = sy-msgv4.
              lwa_return2-parameter  = <lfs_idocno>-docnum.
              append lwa_return2 to li_return2.
            endif.
          when others.
*             Populate the error log.
****************ERROR LOG*********
            clear lwa_return2.
            lwa_return2-type       = c_e.
            lwa_return2-id         = c_zotc_msg.
            lwa_return2-number     = c_025.
            lwa_return2-message_v1 = <lfs_idocno>-docnum.
            append lwa_return2 to li_return2.
        endcase.
      else.
*     If IDoc does not exist, then populating the error log.
****************ERROR LOG*********
        clear lwa_return2.
        lwa_return2-type       = c_e.
        lwa_return2-id         = c_zotc_msg.
        lwa_return2-number     = c_030.
        lwa_return2-message_v1 = <lfs_idocno>-docnum.
        append lwa_return2 to li_return2.
      endif.
    endloop.

    call method me->meth_i_p_applog
      exporting
        im_i_bapiret2 = li_return2.
    refresh li_return2[].
  endif.
endmethod.
ENDCLASS.
