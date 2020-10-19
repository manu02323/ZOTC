FUNCTION zotc_save_text.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CLIENT) LIKE  SY-MANDT DEFAULT SY-MANDT
*"     VALUE(INSERT) TYPE  CHAR10 DEFAULT SPACE
*"     VALUE(SAVEMODE_DIRECT) TYPE  CHAR10 DEFAULT SPACE
*"     VALUE(OWNER_SPECIFIED) TYPE  CHAR10 DEFAULT SPACE
*"     VALUE(LOCAL_CAT) TYPE  CHAR10 DEFAULT SPACE
*"     VALUE(TDOBJECT) TYPE  TDOBJECT OPTIONAL
*"     VALUE(TDNAME) TYPE  TDOBNAME OPTIONAL
*"     VALUE(TDID) TYPE  TDID OPTIONAL
*"     VALUE(TDSPRAS) TYPE  TDSPRAS OPTIONAL
*"  EXPORTING
*"     VALUE(FUNCTION) TYPE  CHAR10
*"     VALUE(NEWHEADER) LIKE  THEAD STRUCTURE  THEAD
*"  TABLES
*"      LINES STRUCTURE  TLINE
*"      LINES_READ STRUCTURE  TLINE
*"  EXCEPTIONS
*"      ID
*"      LANGUAGE
*"      NAME
*"      OBJECT
*"----------------------------------------------------------------------

***********************************************************************
*Program    : ZOTC_SAVE_TEXT                                  *
*Title      : Get Order Details                                       *
*Developer  : ABdus Salam SK                                          *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: SAVE TEXT RFC FM                                        *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*10-Sept-2019   ASK         E2DK927306    Initial Developmentr
*----------------------------------------------------------------------*
  DATA: wa_header TYPE thead.

  CONSTANTS:
        lc_object TYPE tdobject VALUE 'VBBK'. " Order text


**read table header into wa_header index 1.
  wa_header-tdspras = tdspras.
  wa_header-tdobject = tdobject.
  wa_header-tdname = tdname.
  wa_header-tdid = tdid.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client          = client
      header          = wa_header
      insert          = insert
      savemode_direct = savemode_direct
      owner_specified = owner_specified
      local_cat       = local_cat
    IMPORTING
      function        = function
      newheader       = newheader
    TABLES
      lines           = lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

* Get Text
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = wa_header-tdid
      language                = sy-langu
      name                    = wa_header-tdname
      object                  = wa_header-tdobject
    TABLES
      lines                   = lines_read
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    DELETE lines_read WHERE tdline IS INITIAL.
  ENDIF.





ENDFUNCTION.
