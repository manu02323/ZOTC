*&--------------------------------------------------------------------*
*&FUNCTION MODULE    :   ZOTC_MASTERIDOC_CREATE_COND_A                *
* TITLE              :   Creation of IDOC for message type COND_A     *
* DEVELOPER          :  Moushumi Bhattacharya                         *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  This has been copied from MASTERIDOC_CREATE_SMD_COND_A*
*               Some changes have been made in the function           *
*               MASTER_CREATE_COND_A inside the perform EDIDD_FILL_AND*
*              SEND where irrelevant records are getting deleted based*
*               on sy-datum. Just after the function call irrelevant  *
*               change pointers are getting deleted based on sy-datum *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-MAY-2014 MBHATTA1 E2DK902074 INITIAL DEVELOPMENT                 *
* 7-Aug-2014  AROY1    E2DK902074 Defect # 262                        *
* 13-Aug-2014 mthatha  E2DK902074 Defect # 263                        *
*---------------------------------------------------------------------*
FUNCTION zotc_masteridoc_create_cond_a.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MESSAGE_TYPE) LIKE  TBDME-MESTYP
*"     VALUE(CREATION_DATE_HIGH) LIKE  SY-DATUM DEFAULT SY-DATUM
*"     VALUE(CREATION_TIME_HIGH) LIKE  SY-UZEIT DEFAULT SY-UZEIT
*"  EXCEPTIONS
*"      ERROR_CODE_1
*"----------------------------------------------------------------------
  CONSTANTS: max_knumh      TYPE i VALUE 100, " Knumh of type Integers
* Begin of change for D2_OTC_IDD_0093 by MBHATTA1
             lc_datab       TYPE fieldname     VALUE 'DATAB',  " Date
             lc_cond_a      TYPE edi_idoctp    VALUE 'COND_A', " Basic type
             lc_datbi       TYPE fieldname     VALUE 'DATBI'.  " Field Name

* Local Type Declaration
  TYPES: BEGIN OF lty_cdpos,
         objectclas	TYPE cdobjectcl, " Object class
         objectid	  TYPE cdobjectv,  " Object value
         changenr	  TYPE cdchangenr, " Document change number
         tabname    TYPE tabname,    " Table Name
         tabkey	    TYPE cdtabkey,   " Changed table record key
         fname      TYPE fieldname,  " Field Name
         chngind    TYPE cdchngind,  " Change Type (U, I, S, D)
         value_new  TYPE cdfldvaln,  " New contents of changed field
         END OF lty_cdpos.
* End of change for D2_OTC_IDD_0093 by MBHATTA1

  DATA: idoc_must_be_sent   TYPE xfeld, " Checkbox
*       variables for messaging (progress indicator)
        output_total(6),
        output_text(80),
*       sign that work for the current KNUMH is already done
        lv_done             TYPE xfeld, " Checkbox
*       variables for packaging
        lv_pointer_from     TYPE sytabix, " Index of Internal Tables
        lv_pointer_to       TYPE sytabix, " Index of Internal Tables
        lv_knumh_counter    TYPE i.       " Knumh_counter of type Integers

  DATA:
*       table of change pointers
        lt_pointer          TYPE STANDARD TABLE OF bdcp " Change pointer
                                 INITIAL SIZE 10,
*       workarea to store first pointer for a KNUMH
        ls_first_pointer    TYPE bdcp, " Change pointer
*       table of conditions (used for KNUMH)
        lt_conditions       TYPE STANDARD TABLE OF vkkacondit " Gen. Condition Transfer: Condition Key
                                 INITIAL SIZE 10,
*       workarea
        ls_condition        TYPE vkkacondit, " Gen. Condition Transfer: Condition Key
*       temporary table with change IDs
        lt_idents           TYPE STANDARD TABLE OF bdicpident " Change pointer IDs
                                 INITIAL SIZE 10,
* Begin of change for D2_OTC_IDD_0093 by MBHATTA1
        lv_objectid         TYPE cdobjectv,                              " Object value
* Begin of Defect Number 263++
        lv_chgnbr           TYPE cdchangenr,                             "Change Number
* End of Defect Number 263++
        li_cdpos            TYPE STANDARD TABLE OF lty_cdpos,            " Change document items
        wa_cdpos            TYPE lty_cdpos,                              " Change document items
        lt_pointer1         TYPE STANDARD TABLE OF bdcp INITIAL SIZE 10, " Change pointer
        lt_pointer2         TYPE STANDARD TABLE OF bdcp INITIAL SIZE 10. " Change pointer
* End of change for D2_OTC_IDD_0093 by MBHATTA1

  FIELD-SYMBOLS: <pointer>       TYPE bdcp, " Change pointer
* Begin of change for D2_OTC_IDD_0093 by MBHATTA1
                 <lfs_cdpos>     TYPE lty_cdpos, " Change document items
                 <lfs_pointer>   TYPE bdcp.      " Change pointer

  TYPES: BEGIN OF lty_chgno,
          sign   TYPE ddsign,     " Type of SIGN component in row type of a Ranges type
          option TYPE ddoption,   " Type of OPTION component in row type of a Ranges type
          low    TYPE cdchangenr, " Document change number
          high   TYPE cdchangenr, " Document change number
         END OF lty_chgno,

         lty_t_chgno TYPE STANDARD TABLE OF lty_chgno,

         BEGIN OF lty_cdobjid,
          sign   TYPE ddsign,     " Type of SIGN component in row type of a Ranges type
          option TYPE ddoption,   " Type of OPTION component in row type of a Ranges type
          low    TYPE cdobjectv,  " Document change number
          high   TYPE cdobjectv,  " Document change number
         END OF lty_cdobjid,

         lty_t_cdobjid TYPE STANDARD TABLE OF lty_cdobjid,

BEGIN OF lty_changeno,
sign   TYPE ddsign,               " Type of SIGN component in row type of a Ranges type
option TYPE ddoption,             " Type of OPTION component in row type of a Ranges type
low    TYPE cdchangenr,           " Document change number
high   TYPE cdchangenr,           " Document change number
END OF lty_changeno.

  DATA: li_chgno     TYPE lty_t_chgno,
        lwa_changeno TYPE lty_changeno,
        li_changeno TYPE STANDARD TABLE OF lty_changeno,
        lwa_chgno   TYPE lty_chgno,
        lv_count    TYPE int2,       " 2 byte integer (signed)
        lwa_cdobjid TYPE lty_cdobjid,
        lv_cdchgno  TYPE cdchangenr, " Document change number
        li_cdobjid  TYPE lty_t_cdobjid.
* End of change for D2_OTC_IDD_0093 by MBHATTA1

  DEFINE set_msgfn. "==================================================
    case <pointer>-cdchgid.
      when 'I'.
        ls_condition-msgfn = '009'. "create
      when 'U'.
        ls_condition-msgfn = '004'. "change
    endcase.
  END-OF-DEFINITION.

  DEFINE finish_pointers.
*   change pointers will be earmarked for deletion
    call function 'CHANGE_POINTERS_STATUS_WRITE'
      exporting
        message_type           = message_type
      tables
        change_pointers_idents = lt_idents.
*   relieve database and release locks
    commit work.
    call function 'DEQUEUE_ALL'.
  END-OF-DEFINITION. "=================================================


* allow only committed read
  CALL FUNCTION 'DB_SET_ISOLATION_LEVEL'.

* Setzen der Spaltenzahl für Textausgabe.
  NEW-PAGE NO-TITLE LINE-SIZE 120.
  WRITE: / 'Condition exchange based on change documents'(006).
  ULINE.

* determine if the message type must be sent
  CALL FUNCTION 'ALE_MODEL_DETERMINE_IF_TO_SEND'
    EXPORTING
      message_type           = message_type
      validdate              = sy-datum
    IMPORTING
      idoc_must_be_sent      = idoc_must_be_sent
    EXCEPTIONS
      own_system_not_defined = 1
      OTHERS                 = 2.

  IF sy-subrc <> 0.
    WRITE: 'No IDocs can be created !'(015).
  ELSE. " ELSE -> IF sy-subrc <> 0
    IF sy-batch <> 'X'.
      output_text = 'Changes have just been selected'(013).
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          text = output_text.
    ENDIF. " IF sy-batch <> 'X'

*   selection of change pointers (must be selected even if they will be
*   not sent, because the status should be set to 'processed')
    CALL FUNCTION 'CHANGE_POINTERS_READ'
      EXPORTING
        message_type                = message_type
        creation_date_high          = creation_date_high
        creation_time_high          = creation_time_high
        read_not_processed_pointers = 'X'
      TABLES
        change_pointers             = lt_pointer.

*   sort change pointers by KNUMH, change date, tabname and change type
*   (but KONP will be not the first table)
    SORT lt_pointer BY cdobjid cretime tabname cdchgid DESCENDING.

*  Begin of change for D2_OTC_IDD_0093 by MBHATTTA1
    LOOP AT lt_pointer ASSIGNING <pointer>.
***>>> For Each change number it checks that whether something have been changed or not
      IF  lv_cdchgno <> <pointer>-cdchgno
      AND lv_cdchgno IS NOT INITIAL.
        READ TABLE lt_pointer1 TRANSPORTING NO FIELDS
                               WITH KEY fldname = 'DATAB'.
        IF sy-subrc <> 0.
          READ TABLE lt_pointer1 TRANSPORTING NO FIELDS
                                 WITH KEY fldname = 'LOEVM_KO'.
          IF sy-subrc <> 0.
            APPEND LINES OF lt_pointer1 TO lt_pointer2.
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF sy-subrc <> 0
        CLEAR lt_pointer1.
      ENDIF. " IF lv_cdchgno <> <pointer>-cdchgno

      IF <pointer>-fldname = 'LOEVM_KO'.
        lwa_cdobjid-sign = 'I'.
        lwa_cdobjid-option = 'EQ'.
        lwa_cdobjid-low = <pointer>-cdobjid.
        APPEND lwa_cdobjid TO li_cdobjid.
        CLEAR lwa_cdobjid.
      ENDIF. " IF <pointer>-fldname = 'LOEVM_KO'
      IF <pointer>-tabkey+10(8) <= sy-datum
      AND <pointer>-fldname = 'DATAB'.
        lwa_chgno-low = <pointer>-cdchgno.
        lwa_chgno-sign = 'I'.
        lwa_chgno-option = 'EQ'.
        APPEND lwa_chgno TO li_chgno.
        CLEAR lwa_chgno.
      ENDIF. " IF <pointer>-tabkey+10(8) <= sy-datum
      APPEND <pointer> TO lt_pointer1.
      lv_cdchgno = <pointer>-cdchgno.
    ENDLOOP. " LOOP AT lt_pointer ASSIGNING <pointer>
    READ TABLE lt_pointer1 TRANSPORTING NO FIELDS
                           WITH KEY fldname = 'DATAB'.
    IF sy-subrc <> 0.
      READ TABLE lt_pointer1 TRANSPORTING NO FIELDS
                             WITH KEY fldname = 'LOEVM_KO'.
      IF sy-subrc <> 0.
        APPEND LINES OF lt_pointer1 TO lt_pointer2.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc <> 0
    CLEAR lt_pointer1.
    IF li_cdobjid IS NOT INITIAL.
      DELETE lt_pointer WHERE cdobjid IN li_cdobjid.
      CLEAR li_cdobjid.
    ENDIF. " IF li_cdobjid IS NOT INITIAL

    IF li_chgno IS NOT INITIAL.
      DELETE lt_pointer WHERE cdchgno NOT IN li_chgno.
    ENDIF. " if li_chgno is not INITIAL
    IF lt_pointer2 IS NOT INITIAL.
      APPEND LINES OF lt_pointer2 TO lt_pointer.
    ENDIF. " IF lt_pointer2 IS NOT INITIAL
    SORT lt_pointer BY cdobjid cretime tabname cdchgid DESCENDING.
*  End of change for D2_OTC_IDD_0093 by MBHATTTA1

*   no change pointers found: send message
    IF lt_pointer[] IS INITIAL.
      WRITE: /  'Message type'(009) COLOR COL_GROUP,
             16 message_type COLOR COL_NORMAL.
      WRITE: /3 'No formatting necessary'(010).
    ENDIF. " IF lt_pointer[] IS INITIAL

    IF idoc_must_be_sent <> 'X'.
*     nothing to send: mark change pointers as processed nevertheless
      WRITE: / 'Message type'(009) COLOR COL_GROUP,
          message_type COLOR COL_NORMAL,
          30 'No relevant partner system exists'(012).

*     extract pointer IDs into temporary table
      LOOP AT lt_pointer ASSIGNING <pointer>.
        APPEND <pointer>-cpident TO lt_idents.
      ENDLOOP. " LOOP AT lt_pointer ASSIGNING <pointer>
*     mark pointers in lt_idents as processed
      finish_pointers.
*     free temporary table
      FREE lt_idents.
    ELSE. " ELSE -> IF idoc_must_be_sent <> 'X'
*     Build temporary table with conditions (KNUMH) from change
*     pointers. Each KNUMH should appear only once.

      lv_pointer_from = 1.
      DO.
*       build output table from change pointers
        LOOP AT lt_pointer FROM lv_pointer_from ASSIGNING <pointer>.
          lv_pointer_to = sy-tabix.
*         check if the KNUMH isn't done
          CHECK NOT ( <pointer>-cdobjid = ls_first_pointer-cdobjid AND
                      lv_done = 'X' ).
          IF <pointer>-cdobjid <> ls_first_pointer-cdobjid.
*           package size reached: interrupt the loop
            IF lv_knumh_counter = max_knumh.
              lv_pointer_to = sy-tabix - 1.
              EXIT.
            ENDIF. " IF lv_knumh_counter = max_knumh
*           take over new condition record number
            ls_condition-knumh = <pointer>-cdobjid.
            set_msgfn.
            APPEND ls_condition TO lt_conditions.
            MOVE <pointer> TO ls_first_pointer.
            ADD 1 TO lv_knumh_counter.
            lv_done = space.
          ELSE. " ELSE -> IF lv_knumh_counter = max_knumh
            IF <pointer>-cretime <> ls_first_pointer-cretime.
*             no more active changes: done
              lv_done = 'X'.
*           prefer KONP: allow change of MSGFN
            ELSEIF <pointer>-tabname <> ls_first_pointer-tabname AND
                   <pointer>-tabname = 'KONP'.
              set_msgfn.
              sy-tabix = lines( lt_conditions ).
              MODIFY lt_conditions FROM ls_condition
                INDEX sy-tabix TRANSPORTING msgfn.
              lv_done = 'X'.
            ENDIF. " IF <pointer>-cretime <> ls_first_pointer-cretime
          ENDIF. " IF <pointer>-cdobjid <> ls_first_pointer-cdobjid
        ENDLOOP. " LOOP AT lt_pointer FROM lv_pointer_from ASSIGNING <pointer>

*       no more change pointers: exit from do-enddo
        IF sy-subrc <> 0.
          EXIT.
        ENDIF. " IF sy-subrc <> 0

        IF sy-batch <> 'X'.
*         not in batch mode: show progress indicator with number of
*         processed condition records
          output_text =
         'IDocs for & condition changes being created'(014). " 'idocs of type
          output_total = lines( lt_conditions ).
          REPLACE '&' IN output_text WITH output_total.
          CONDENSE output_text.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              text = output_text.
        ENDIF. " IF sy-batch <> 'X'

*  Begin of change for D2_OTC_IDD_0093 by MBHATTTA1
***>>> Corresponding Import have been done from Enhancement Implementation
***>>> ZIM_CONDITION_FILTER in order to identify that BD21 transaction was executed
        CALL FUNCTION 'ZOTC_SET_VALUE'
          EXPORTING
            im_flag2 = abap_true.
*  End of change for D2_OTC_IDD_0093 by MBHATTTA1

*       start processing and send data
        CALL FUNCTION 'MASTERIDOC_CREATE_COND_A'
          EXPORTING
            pi_mestyp                 = message_type
            pi_logsys                 = space
            pi_direkt                 = space
          TABLES
            pit_conditions            = lt_conditions
          EXCEPTIONS
            idoc_could_not_be_created = 1.

        IF sy-subrc = 0.
*  Begin of change for D2_OTC_IDD_0093 by MBHATTTA1
***>>> Filtering out the unwanted condition records
          LOOP AT lt_pointer ASSIGNING <lfs_pointer>.
* No Need to sort the following table before read because it is coming from standard SAP
* and will not contain huge number of entries.
            READ TABLE lt_conditions TRANSPORTING NO FIELDS
                                     WITH KEY knumh = <lfs_pointer>-cdobjid.
** ---> Begin of Change/Insert/Delete for D2_OTC_IDD_0093 by mthatha
            IF sy-subrc <> 0.
              CLEAR <lfs_pointer>-cdobjid.
            ENDIF. " IF sy-subrc <> 0
          ENDLOOP. " LOOP AT lt_pointer ASSIGNING <lfs_pointer>
          DELETE lt_pointer WHERE cdobjid IS INITIAL.
          IF lt_pointer IS NOT INITIAL.
            SELECT objectclas " Object class
                   objectid   " Object value
                   changenr   " Document change number
                   tabname    " Table Name
                   tabkey     " Changed table record key
                   fname      " Field Name
                   chngind    " Change Type (U, I, S, D)
                   value_new  " New contents of changed field
                   FROM cdpos " Change document items
                   INTO TABLE li_cdpos
                   FOR ALL ENTRIES IN lt_pointer
                   WHERE objectclas = lc_cond_a
                   AND objectid = lt_pointer-cdobjid.
            IF sy-subrc IS INITIAL AND li_cdpos IS NOT INITIAL.
              DELETE li_cdpos WHERE fname <> lc_datab.
              SORT li_cdpos BY objectclas objectid value_new.
***>>> Getting the correct date and correect condition record number
** ---> Begin of Change/Insert/Delete for D2_OTC_IDD_0093 by mthatha
              LOOP AT li_cdpos ASSIGNING <lfs_cdpos> WHERE fname = lc_datab.
                IF ( <lfs_cdpos>-objectid <> lv_objectid
* Begin of Defect Number 263++
                  OR <lfs_cdpos>-changenr <> lv_chgnbr )
* End of Defect Number 263++
                AND lv_objectid IS NOT INITIAL
                AND wa_cdpos-changenr IS NOT INITIAL.
                  lwa_changeno-low = wa_cdpos-changenr.
                  lwa_changeno-sign = 'I'.
                  lwa_changeno-option = 'EQ'.
                  APPEND lwa_changeno TO li_changeno.
                  CLEAR lwa_changeno.
                  CLEAR lv_count.
                  CLEAR wa_cdpos.
                ENDIF. " IF <lfs_cdpos>-objectid <> lv_objectid
                IF <lfs_cdpos>-value_new LE sy-datum.
                  wa_cdpos = <lfs_cdpos>.
                ENDIF. " IF <lfs_cdpos>-value_new LE sy-datum
                lv_objectid  = <lfs_cdpos>-objectid.
* Begin of Defect Number 263++
                lv_chgnbr    = <lfs_cdpos>-changenr.
* End of Defect Number 263++
              ENDLOOP. " LOOP AT li_cdpos ASSIGNING <lfs_cdpos> WHERE fname = lc_datab
* Begin of Defect Number 262++
              IF wa_cdpos-changenr IS NOT INITIAL.
                lwa_changeno-low = wa_cdpos-changenr.
                lwa_changeno-sign = 'I'.
                lwa_changeno-option = 'EQ'.
                APPEND lwa_changeno TO li_changeno.
                CLEAR lwa_changeno.
                CLEAR wa_cdpos.
              ENDIF. " IF wa_cdpos-changenr IS NOT INITIAL
* End of Defect Number 262++
              IF li_changeno IS NOT INITIAL.
                DELETE lt_pointer WHERE cdchgno NOT IN li_changeno.
              ENDIF. " IF li_changeno IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL AND li_cdpos IS NOT INITIAL
          ENDIF. " IF lt_pointer IS NOT INITIAL

          IF lt_pointer2 IS NOT INITIAL.
            APPEND LINES OF lt_pointer2 TO lt_pointer.
          ENDIF. " IF lt_pointer2 IS NOT INITIAL
* End of change for D2_OTC_IDD_0093 by MBHATTTA1
          REFRESH lt_conditions.
*         extract pointer IDs into temporary table
          LOOP AT lt_pointer FROM lv_pointer_from TO lv_pointer_to
            ASSIGNING <pointer>.
            APPEND <pointer>-cpident TO lt_idents.
          ENDLOOP. " LOOP AT lt_pointer FROM lv_pointer_from TO lv_pointer_to
*         mark pointers in lt_idents as processed
          finish_pointers.
*         go ahead
          REFRESH lt_idents.
          lv_pointer_from  = lv_pointer_to + 1.
          lv_pointer_to    = lv_pointer_from.
          lv_knumh_counter = 0.
        ELSE. " ELSE -> IF lt_pointer2 IS NOT INITIAL
          WRITE: 'No IDocs can be created !'(015).
          EXIT.
        ENDIF. " IF sy-subrc = 0
      ENDDO.
      FREE: lt_conditions, lt_idents.
    ENDIF. " IF idoc_must_be_sent <> 'X'
  ENDIF. " IF sy-subrc <> 0

* back again to dirty read
  CALL FUNCTION 'DB_RESET_ISOLATION_TO_DEFAULT'.

ENDFUNCTION.
