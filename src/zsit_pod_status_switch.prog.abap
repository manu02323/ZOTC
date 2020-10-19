*&---------------------------------------------------------------------*
*& Report ZSIT_POD_STATUS_SWITCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&-----------------------------------------------------------------------------*
*& Report  ZSIT_POD_STATUS_SWITCH
*&
*&-----------------------------------------------------------------------------*
*& Special correction program from OSS note 2612353
*& This program will toggle the proof-of-delivery status of a delivery
*& between 'A' = 'relevant' and 'C' = 'confirmed'.
*& It is meant as an emergency tool for inconsistent situatione where
*& the POD process has not happened correctly (no material document created)
*& but the POD status is nevertheless 'confirmed', or the opposite case,
*& where the POD material document was created, but the POD status is still 'A'.
*&
*& WARNING: the program does a hard update on the database. There are no checks,
*& no locks etc, so use with extreme care and only if you are absolutely sure
*& that it is OK to change the status that way.
*&
*& March 2018, D058337
*&-----------------------------------------------------------------------------*

REPORT ZSIT_POD_STATUS_SWITCH.

TABLES: likp.

SELECT-OPTIONS: so_vbeln FOR likp-vbeln MATCHCODE OBJECT vmvl.
PARAMETERS: p_test  TYPE c DEFAULT 'X'.

DATA:
  lt_vbuk         TYPE SORTED TABLE OF vbuk WITH UNIQUE KEY vbeln,
  ls_vbuk         LIKE LINE OF lt_vbuk,
  ls_vbup         TYPE vbup,
  lv_lines        TYPE i,
  lv_curr_status  TYPE pdstk,
  lv_new_status   TYPE pdstk,
  lv_message(200) TYPE c.

START-OF-SELECTION.

* only allow for list of explicit delivery number, no ranges, no wildcards
  DESCRIBE TABLE so_vbeln LINES lv_lines.
  LOOP AT so_vbeln TRANSPORTING NO FIELDS
    WHERE sign <> 'I'
       OR option <> 'EQ'.
  ENDLOOP.
  IF sy-subrc = 0 OR lv_lines = 0.
    MESSAGE e000(xt) WITH 'Only a list of delivery numbers is allowed,' 'no ranges, wildcards etc.!'.
    EXIT.
  ENDIF.

* select list of delivery numbers to be processed by their status entries
  SELECT * FROM vbuk INTO TABLE lt_vbuk
    WHERE vbeln IN so_vbeln.
  IF sy-subrc <> 0.
    MESSAGE i000(xt) WITH 'No deliveries found!'.
    EXIT.
  ENDIF.

* process one by one
  LOOP AT lt_vbuk INTO ls_vbuk.

    CLEAR: lv_curr_status, lv_new_status.

    IF ls_vbuk-pdstk = 'A'.           " POD relevant, but status not CONFIRMED'
      lv_new_status = 'C'.
    ELSEIF ls_vbuk-pdstk = 'C'.       " POD status is CONFIRMED
      lv_new_status = 'A'.
    ELSE.
      CONCATENATE 'Delivery has POD status''' ls_vbuk-pdstk ''' and is ignored!'
        INTO lv_message SEPARATED BY space.
      MESSAGE i000(xt) WITH lv_message(50) lv_message+50(50) lv_message+100(50).
      EXIT.
    ENDIF.

*   change POD status of header and item
    IF NOT lv_new_status IS INITIAL.

      lv_curr_status = ls_vbuk-pdstk.
      ls_vbuk-pdstk = lv_new_status.

      UPDATE vbuk FROM ls_vbuk.

      SELECT * FROM vbup INTO ls_vbup
        WHERE vbeln = ls_vbuk-vbeln AND pdsta = lv_curr_status.

        ls_vbup-pdsta = lv_new_status.
        UPDATE vbup FROM ls_vbup.

      ENDSELECT.

      IF p_test IS INITIAL.
        COMMIT WORK.
        MESSAGE i000(xt) WITH 'POD status of delivery' ls_vbuk-vbeln 'has been changed to' lv_new_status.
      ELSE.
        ROLLBACK WORK.
        MESSAGE i000(xt) WITH 'TEST MODE: POD status of delivery' ls_vbuk-vbeln 'would be changed to' lv_new_status.
      ENDIF.

    ENDIF.

  ENDLOOP.

