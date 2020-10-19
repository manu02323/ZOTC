*&---------------------------------------------------------------------*
*& Report  ZE1EDP19
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZE1EDP19.
TABLES: idocsyn, edisyn, cimsyn.

DATA: old_idocsyn TYPE idocsyn,
      lt_idocsyn  TYPE STANDARD TABLE OF idocsyn,
      ls_idocsyn  TYPE idocsyn,
      old_edisyn  TYPE edisyn,
      lt_edisyn   TYPE STANDARD TABLE OF edisyn,
      ls_edisyn   TYPE edisyn.

PARAMETER idoc_typ TYPE idocsyn-idoctyp DEFAULT 'ORDERS05'.
PARAMETER idoc_seg TYPE idocsyn-segtyp  DEFAULT 'E1EDP19'.
PARAMETER occmax   TYPE idocsyn-occmax  DEFAULT '99'.
PARAMETER upd_flag AS   CHECKBOX        DEFAULT space.

START-OF-SELECTION.

* table IDOCSYN
  SELECT * FROM idocsyn
         INTO TABLE lt_idocsyn
         WHERE idoctyp = idoc_typ.

  READ TABLE lt_idocsyn INTO ls_idocsyn
                        WITH KEY idoctyp = idoc_typ
                                 segtyp  = idoc_seg.
  IF sy-subrc = 0.
    MOVE ls_idocsyn TO old_idocsyn.
    ls_idocsyn-occmax = occmax.
    IF upd_flag EQ 'X'.
      UPDATE idocsyn FROM ls_idocsyn.
      WRITE: 'Table IDOCSYN updated',
             /,'         Idoctype:      ',idoc_typ,
             /'         segment number: ',ls_idocsyn-nr.

      WRITE: /,'OCCMAX changed from',old_idocsyn-occmax,
             ' to ',ls_idocsyn-occmax.
    ELSE.
      WRITE: 'No UPDATE done in table IDOCSYN',
             /,'         Idoctype:      ',idoc_typ,
             /'         segment number: ',ls_idocsyn-nr.

      WRITE: /,'OCCMAX changed from',old_idocsyn-occmax,
             ' to ',ls_idocsyn-occmax.
    ENDIF.
  ELSE.
    WRITE: 'no such record in table IDOCSYN'.
  ENDIF.
  ULINE.

* table EDISYN
  SELECT * FROM edisyn
         INTO TABLE lt_edisyn
         WHERE idoctyp = idoc_typ AND
               cimtyp  = space.
  READ TABLE lt_edisyn INTO ls_edisyn
                       WITH KEY idoctyp = idoc_typ
                                cimtyp  = space
                                segtyp  = idoc_seg.
  IF sy-subrc = 0.
    MOVE ls_edisyn TO old_edisyn.
    ls_edisyn-occmax = occmax.
    IF upd_flag EQ 'X'.
      UPDATE edisyn FROM ls_edisyn.
      WRITE: 'Table EDISYN updated',
             /,'         Idoctype:      ',idoc_typ,
             /'         segment number: ', ls_edisyn-posno.

      WRITE: /,'OCCMAX changed from',old_edisyn-occmax,
             ' to ',ls_edisyn-occmax.
    ELSE.
      WRITE: 'No UPDATE done in table EDISYN',
             /,'         Idoctype:      ',idoc_typ,
             /'         segment number: ',ls_idocsyn-nr.

      WRITE: /,'OCCMAX changed from',old_idocsyn-occmax,
             ' to ',ls_idocsyn-occmax.
    ENDIF.
  ELSE.
    WRITE: 'no such record in table EDISYN'.
  ENDIF.
