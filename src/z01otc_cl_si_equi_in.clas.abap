class Z01OTC_CL_SI_EQUI_IN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_EQUI_IN .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CL_SI_EQUI_IN IMPLEMENTATION.


METHOD z01otc_ii_si_equi_in~si_equi_in.

***********************************************************************
*Program    : Z01OTC_II_SI_EQUI_IN~SI_EQUI_IN(Proxy Method)           *
*Title      : Update Equipment Master                                 *
*Developer  : Harshit Badlani                                         *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0096                                           *
*---------------------------------------------------------------------*
*Description: Service Max will send equipment installation related    *
*data, with material and serial number to Enterprise Services via SOA.*
*Enterprise Services will update the necessary equipment installation *
*details in SAP .                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*29-May-2014  HBADLAN       E2DK900879      INITIAL DEVELOPMENT
*21-Jul-2014  HBADLAN       E2DK900879      HPALM Defect #107
*23-Dec-2014  SGUPTA4       E2DK900879      Defect #2597
*---------------------------------------------------------------------*

*Local data declarations.
  DATA : lwa_equipment      TYPE z01otc_dt_equi_req_equipment,  "Proxy Structure (generated)
         lwa_obj            TYPE bgmkobj_rfc,                   "Master Warranty - Object Link RFC Input
         lwa_data_general   TYPE bapi_itob,                     "PM: BAPI Structure for ITOBAPI_CREATE + READ Fields
         lwa_data_specific  TYPE bapi_itob_eq_only,             "PM: BAPI Structure for ITOBAPI_CREATE_EQ_ONLY + READ Fields
         lwa_data_specificx TYPE bapi_itob_eq_onlyx,            "PM: Indicator Structure for BAPI_ITOB_EQ_ONLY (Change BAPI)
         lwa_return         TYPE bapiret2,                      "Return Parameter
         lwa_data_generalx  TYPE bapi_itobx,                    "PM: Flag Structure for BAPI_ITOB (For Change BAPIs)
         lv_string         TYPE string,                         "Var. for storing string
         lv_matnr          TYPE matnr,                          "Material Number
         lv_sernr          TYPE gernr,                          "Serial Number
         lv_equnr          TYPE equnr,                          "Equipment Number
         lv_objnr          TYPE j_objnr,                        "Object number
         lv_note           TYPE sapplco_log_item_note,          "A short text for the log message
         lv_warranty_flag  TYPE flag,                           "Flag for Warranty data updation check
         lv_bapi_flag      TYPE flag,                           "Flag for Bapi success check
         lv_max_sev_code   TYPE sapplco_log_item_severity_code, "Maximum severity code
         lv_type_id        TYPE sapplco_log_item_type_id,       " Unique identification of the type of a log entry
         lwa_output_item   TYPE sapplco_log_item,               "Protocol message issued by an application
         li_obj            TYPE STANDARD TABLE OF bgmkobj_rfc,  "Master Warranty - Object Link RFC Input
         li_enq            TYPE STANDARD TABLE OF seqg3,        "to get the return values
         li_output_item    TYPE sapplco_log_item_tab.           "protocol message issued by an application

*Local constant declaration

  CONSTANTS:lc_sev_code_3        TYPE sapplco_log_item_severity_code VALUE '3', "Error Sev code
            lc_sev_code_5        TYPE sapplco_log_item_severity_code VALUE '5', "Success Sev code
            lc_cust_warranty     TYPE gaart       VALUE '1',                    "Customer Warranty
            lc_subrc_1           TYPE sysubrc     VALUE '1',                    "Return Value of ABAP Statements
            lc_subrc_2           TYPE sysubrc     VALUE '2',                    "Return Value of ABAP Statements
            lc_subrc_3           TYPE sysubrc     VALUE '3',                    "Return Value of ABAP Statements
            lc_subrc_4           TYPE sysubrc     VALUE '4',                    "Return Value of ABAP Statements
            lc_subrc_5           TYPE sysubrc     VALUE '5',                    "Return Value of ABAP Statements
            lc_subrc_6           TYPE sysubrc     VALUE '6',                    "Return Value of ABAP Statements
            lc_bracket1          TYPE char1       VALUE '(',                    "Bracket1 of type CHAR1
            lc_bracket2          TYPE char1       VALUE ')',                    "Bracket2 of type CHAR1
            lc_table             TYPE eqegraname  VALUE 'EQUI',                 "table to be locked:'ZLEX_BLEED'
            lc_error             TYPE bapi_mtype  VALUE 'E',                    "Message type: E Error
            lc_abort             TYPE bapi_mtype  VALUE 'A',                    "Message type: A Abort
*Begin of change for HPALM Defect #107
            lc_bus_code_3        TYPE sapplco_processing_result_code VALUE '3', "Business doc processing success code
            lc_bus_code_5        TYPE sapplco_processing_result_code VALUE '5'. "Business doc processing error code
*End of change for HPALM Defect #107

  FIELD-SYMBOLS  : <lfs_enq>        TYPE  seqg3. "dialog Fields for Lock Display/Delete SM12

*Following statement switches the local update on
  SET UPDATE TASK LOCAL. "Required for proxy

  lwa_equipment = input-mt_equi_req-equipment. "Equipment no.
  lv_matnr     = lwa_equipment-material_number. "Material No.
  lv_sernr     = lwa_equipment-serial_number. "Serial no.

* ---> Begin of of Insert for D2_OTC_IDD_0096, Defect #2597 by SGUPTA4

CALL FUNCTION 'CONVERSION_EXIT_GERNR_INPUT'
  EXPORTING
    input         = lv_sernr
 IMPORTING
   OUTPUT        = lv_sernr.
* <--- End   of Insert for D2_OTC_IDD_0096, Defect #2597 by SGUPTA4

*Fetching unique Equipment and Object no. based on material
*and serial number.
  SELECT  equnr " Equipment Number
          objnr " Object number
  UP TO 1 ROWS
  INTO (lv_equnr, lv_objnr )
  FROM  equi    " Equipment master data
  WHERE sernr = lv_sernr
  AND   matnr = lv_matnr.
  ENDSELECT.

*If Equipment no. exists proceed for updation
*else give error message.
  IF sy-subrc EQ 0.
*Passing equipment no. to output.
    output-mt_equi_res-equipment-equip_id = lv_equnr.

*Calling FM for LOCKING THE EQIPMENT ENRTY
    CALL FUNCTION 'ENQUEUE_EIEQUI'
      EXPORTING
        mode_equi      = 'E'
        mandt          = sy-mandt
        equnr          = lv_equnr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*If table is locked by other user then retreive the user id of the
*that user using the below FM and give it in the error message.
      CALL FUNCTION 'ENQUEUE_REPORT'
        EXPORTING
          gclient               = sy-mandt
          gname                 = lc_table "table to be locked:'EQUI'
          guname                = '*'
        TABLES
          enq                   = li_enq
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc EQ 0.
        SORT li_enq BY gname.
*to retrieve the user name from the returning table who has currently
*locked the custom table
        READ TABLE li_enq ASSIGNING <lfs_enq> WITH KEY gname = lc_table
                                              BINARY SEARCH.
        IF sy-subrc EQ 0. "If entry exists
          MESSAGE s601(mc) WITH <lfs_enq>-guname " Object requested is currently locked by user &
                            INTO lv_note.        " Object requested is currently locked by user &
          lwa_output_item-note = lv_note.
          lwa_output_item-type_id = '601(MC)'.
          lwa_output_item-severity_code = lc_sev_code_3. "ERROR
          lv_max_sev_code = lc_sev_code_3.
          APPEND lwa_output_item TO li_output_item.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc <> 0
    ELSE. " ELSE -> IF sy-subrc EQ 0

*Calling FM for Updation of Warranty dates
*It's a RFC FM. So calling with destination 'None'.

*Setting up data to be passed to FM
      lwa_obj-objnr = lv_objnr. "Technical Object for Warranty Check
      lwa_obj-gaart = lc_cust_warranty. " 1 for customer warranty

      IF lwa_equipment-warranty_start_date IS NOT INITIAL.
        lwa_obj-gwldt = lwa_equipment-warranty_start_date. "Warranty Date
        lv_string = 'WarrantyStartDate'(007).
      ENDIF. " IF lwa_equipment-warranty_start_date IS NOT INITIAL

      IF lwa_equipment-warranty_end_date IS NOT INITIAL.
        lwa_obj-gwlen = lwa_equipment-warranty_end_date. "Date on which the warranty end
        CONCATENATE lv_string  'WarrantyEndDate'(008) INTO lv_string
                                                      SEPARATED BY space.
      ENDIF. " IF lwa_equipment-warranty_end_date IS NOT INITIAL
 "LI_OBJ will only have one line of data.
      APPEND lwa_obj TO li_obj.

*If lv_string is initial, which will happen when both start and end dates
*will be blank ,then no need to update.
      IF  lv_string IS NOT INITIAL .
        CALL FUNCTION 'WARRANTY_ASSIGNMENT_RFC'
          DESTINATION 'NONE'
          TABLES
            i_obj_wa                = li_obj
          EXCEPTIONS
            invalid_object_number   = 1
            invalid_warranty_number = 2
            no_entry                = 3
            update_error            = 4
            invalid_watype          = 5
            OTHERS                  = 6.

        IF sy-subrc EQ 0.
*If Update thru FM is success then message is populated in log.
          lv_warranty_flag = abap_true. " For Warranty updation success check
          MESSAGE s151(zotc_msg) WITH lv_string " Field & Updated for Equipment & .
                                      lv_equnr
                                 INTO lv_note.
          lwa_output_item-note = lv_note.
          lwa_output_item-type_id = '151(ZOTC_MSG)'.
          lwa_output_item-severity_code = lc_sev_code_5. "Success
          APPEND lwa_output_item TO li_output_item.

        ELSE. " ELSE -> IF sy-subrc EQ 0
*If FM failes to update,then messgae is populated with
*that exception and populated in output log.
          CASE sy-subrc.
            WHEN lc_subrc_1.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
              WITH 'Invalid Object Number'(001)
              INTO lv_note.

            WHEN lc_subrc_2.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
              WITH 'Invalid warranty number'(002)
              INTO lv_note.

            WHEN lc_subrc_3.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
             WITH 'No entry'(003)
             INTO lv_note.

            WHEN lc_subrc_4.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
              WITH 'Update error'(004)
              INTO lv_note.

            WHEN lc_subrc_5.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
              WITH 'Invalid watype'(005)
              INTO lv_note.

            WHEN lc_subrc_6.
              MESSAGE s141(zotc_msg) " Warranty dates updation failed with error &.
              WITH 'Unknown error'(006)
              INTO lv_note.
          ENDCASE.

          lwa_output_item-note = lv_note.
          lwa_output_item-type_id = '141(ZOTC_MSG)'.
          lwa_output_item-severity_code = lc_sev_code_3. "Error
          lv_max_sev_code = lc_sev_code_3.
          APPEND lwa_output_item TO li_output_item.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_string IS NOT INITIAL

*Calling FM for Unlock Equipment entry.
      CALL FUNCTION 'DEQUEUE_EIEQUI'
        EXPORTING
          mandt = sy-mandt
          equnr = lv_equnr.
*************************************
*WARRANTY ID (SORT FIELD) AND INSTALLATION DATE ( START UP DATE OT TECH OBJECT)
*UPDATION.
      IF ( ( lwa_equipment-install_date IS NOT INITIAL ) OR ( lwa_equipment-warranty_id IS NOT INITIAL ) ).
        CLEAR : lv_string,
                lv_note,
                lwa_output_item.

*If warranty Id is not blank.
        IF  lwa_equipment-warranty_id IS NOT INITIAL .
          lwa_data_general-sortfield   = lwa_equipment-warranty_id. "Warranty ID
          lwa_data_generalx-sortfield  = abap_true. "X
          lv_string = 'WarrantyID'(009) .
        ENDIF. " IF lwa_equipment-warranty_id IS NOT INITIAL

*If start up date is not blank
        IF ( lwa_equipment-install_date IS NOT INITIAL ).
          lwa_data_general-start_from  = lwa_equipment-install_date. "Start-up date
          lwa_data_generalx-start_from = abap_true. "X
          CONCATENATE lv_string 'InstallDate'(010) INTO lv_string
                                                   SEPARATED BY space.
        ENDIF. " IF ( lwa_equipment-install_date IS NOT INITIAL )

*BAPI call for updation of Warranty ID and Start up date.
        CALL FUNCTION 'BAPI_EQUI_CHANGE'
          EXPORTING
            equipment      = lv_equnr "Equipment no.
            data_general   = lwa_data_general
            data_generalx  = lwa_data_generalx
            data_specific  = lwa_data_specific
            data_specificx = lwa_data_specificx
          IMPORTING
            return         = lwa_return.

*If message type of return structure is 'ERROR' or 'ABORT' the Rollback
*else Commit work.
        IF ( ( lwa_return-type EQ lc_error ) OR ( lwa_return-type EQ lc_abort ) ).
*Trigger a rollback, if an error occured during update of the
*equipment master
          CALL METHOD cl_soap_commit_rollback=>rollback( ).
*Show error message in output log.
          CONCATENATE lwa_return-number lc_bracket1 lwa_return-id lc_bracket2 INTO lv_type_id.
          lwa_output_item-type_id = lv_type_id.
          lwa_output_item-note   = lwa_return-message.
          lwa_output_item-severity_code = lc_sev_code_3. "Error.
          lv_max_sev_code = lc_sev_code_3.
          APPEND lwa_output_item TO li_output_item.

        ELSE. " ELSE -> IF ( ( lwa_return-type EQ lc_error ) OR ( lwa_return-type EQ lc_abort ) )

*Commit work if update is success. Also populate success message in output log.
          lv_bapi_flag = abap_true.
          MESSAGE s151(zotc_msg) WITH lv_string " Field & Updated for Equipment & .
                                      lv_equnr
                                 INTO lv_note.

          lwa_output_item-note = lv_note.
          lwa_output_item-type_id = '151(ZOTC_MSG)'.
          lwa_output_item-severity_code = lc_sev_code_5. "Success
          APPEND lwa_output_item TO li_output_item.
        ENDIF. " IF ( ( lwa_return-type EQ lc_error ) OR ( lwa_return-type EQ lc_abort ) )
      ENDIF. " IF ( ( lwa_equipment-install_date IS NOT INITIAL ) OR ( lwa_equipment-warranty_id IS NOT INITIAL ) )
    ENDIF. " IF sy-subrc EQ 0
*If equipment no. not found
  ELSE. " ELSE -> IF ( lwa_equipment-install_date IS NOT INITIAL )

*Message "No equipment found for Material & Serial &
    MESSAGE e139(zotc_msg) WITH lv_matnr " No record found for external partner & partner role &
                                lv_sernr
                           INTO lv_note.

    lwa_output_item-note = lv_note.
    lwa_output_item-type_id = '139(ZOTC_MSG)'.
    lwa_output_item-severity_code = lc_sev_code_3. "Error
    lv_max_sev_code = lc_sev_code_3.
    APPEND lwa_output_item TO li_output_item.
  ENDIF. " IF sy-subrc EQ 0

*If either of FM is successful then COMMIT WORK.
  IF ( ( lv_warranty_flag EQ abap_true ) OR ( lv_bapi_flag EQ abap_true ) ).
    CALL METHOD cl_soap_commit_rollback=>commit.
  ENDIF. " IF ( ( lv_warranty_flag EQ abap_true ) OR ( lv_bapi_flag EQ abap_true ) )

*Populating maximum sev code (If error happens even once max sev code is '3' else
*if everything goes success then max sev code is '5'
  IF lv_max_sev_code IS INITIAL.
    output-mt_equi_res-equipment-log-maximum_log_item_severity_code = lc_sev_code_5.
*Begin of change for HPALM Defect #107
    output-mt_equi_res-equipment-log-business_document_processing = lc_bus_code_3.
*End of change for HPALM Defect #107
  ELSE. " ELSE -> IF lv_max_sev_code IS INITIAL
    output-mt_equi_res-equipment-log-maximum_log_item_severity_code = lv_max_sev_code.
*Begin of change for HPALM Defect #107
    output-mt_equi_res-equipment-log-business_document_processing = lc_bus_code_5.
*End of change for HPALM Defect #107
  ENDIF. " IF lv_max_sev_code IS INITIAL

*Appending messages into output log.
  IF li_output_item IS NOT INITIAL.
    APPEND LINES OF li_output_item TO output-mt_equi_res-equipment-log-item.
  ENDIF. " IF li_output_item IS NOT INITIAL
ENDMETHOD.
ENDCLASS.
