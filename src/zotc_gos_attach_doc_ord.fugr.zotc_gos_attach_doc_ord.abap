FUNCTION zotc_gos_attach_doc_ord.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_XSTRING) TYPE  XSTRING
*"     REFERENCE(IM_VBELN) TYPE  VBELN
*"     REFERENCE(IM_FNAME) TYPE  STRING
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_GOS_ATTACH_DOC_ORD(FM)                             *
*Title      : FM to attach doc to Order GOS object                    *
*Developer  : Raghahv Sureddi (U033876)                               *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222                                              *
*---------------------------------------------------------------------*
*Description: SCTASK0768763  -FM to attach doc to Order GOS object    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*24-Nov-2018   U033876       E1DK939532     Initial Development
*---------------------------------------------------------------------*
  DATA :  ls_fol_id     TYPE soodk,                   " SAPoffice: Definition of an Object (Key Part)
          ls_obj_id     TYPE soodk,                   " SAPoffice: Definition of an Object (Key Part)
          ls_obj_data   TYPE sood1,                   " SAPoffice: object definition, change attributes
          ls_objhead    TYPE soli,                    " SAPoffice: line, length 255
          lv_key        TYPE swo_typeid,              " Object key
          lv_type       TYPE swo_objtyp,
          ls_object     TYPE borident,                " Object Relationship Service: BOR object identifier
          ls_folmem_k   TYPE sofmk,                   " SAPoffice: folder contents (key part)
          lv_ep_note    TYPE borident-objkey,         " Object key
          ls_note       TYPE borident,                " Object Relationship Service: BOR object identifier
          lv_name       TYPE string,
          lv_extension  TYPE string,
          lv_offset     TYPE i,                       " Offset of type Integers
          lv_size       TYPE i,                       " Size of type Integers
          lv_temp_len   TYPE i,                       " Temp_len of type Integers
          lv_offset_old TYPE i,                       " Offset_old of type Integers
          lt_doc_content TYPE solix_tab,
          lt_cont        TYPE soli_tab,
          lt_objhead     TYPE STANDARD TABLE OF soli. " SAPoffice: line, length 255

*-----Folder Root

  CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
    EXPORTING
*     OWNER                 = ' '
      region                = 'B'
    IMPORTING
      folder_id             = ls_fol_id
    EXCEPTIONS
      communication_failure = 1
      owner_not_exist       = 2
      system_failure        = 3
      x_error               = 4
      OTHERS                = 5.

  CHECK sy-subrc = 0.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer          = im_xstring
      append_to_table = abap_true
    TABLES
      binary_tab      = lt_doc_content.


  CALL FUNCTION 'SO_SOLIXTAB_TO_SOLITAB'
    EXPORTING
      ip_solixtab = lt_doc_content
    IMPORTING
      ep_solitab  = lt_cont.

  SPLIT im_fname AT '.' INTO lv_name lv_extension.
*  lv_extension = 'PDF'.
  TRANSLATE lv_extension TO UPPER CASE .

  ls_obj_data-objsns    = 'O'.

  ls_obj_data-objla     = sy-langu.

  ls_obj_data-objdes    = 'ATTACH' .

  ls_obj_data-file_ext  = lv_extension.

  ls_obj_data-objlen    = lines( lt_cont ) * 255.

  CONCATENATE '&SO_FILENAME=' lv_name '.' lv_extension INTO ls_objhead-line.

  APPEND ls_objhead TO lt_objhead.

  ls_objhead-line = '&SO_FORMAT=BIN'.

  APPEND ls_objhead TO lt_objhead.

  CALL FUNCTION 'SO_OBJECT_INSERT'
    EXPORTING
      folder_id             = ls_fol_id
      object_type           = 'EXT'
      object_hd_change      = ls_obj_data
    IMPORTING
      object_id             = ls_obj_id
    TABLES
      objhead               = lt_objhead
      objcont               = lt_cont
    EXCEPTIONS
      active_user_not_exist = 35
      folder_not_exist      = 6
      object_type_not_exist = 17
      owner_not_exist       = 22
      parameter_error       = 23
      OTHERS                = 1000.

  IF sy-subrc EQ 0 .

* attach document as GOS attacment to realted bussiness object

    ls_object-objkey  = im_vbeln.

    ls_object-objtype = 'BUS2032'.

    ls_folmem_k-foltp = ls_fol_id-objtp.

    ls_folmem_k-folyr = ls_fol_id-objyr.

    ls_folmem_k-folno = ls_fol_id-objno.

    ls_folmem_k-doctp = ls_obj_id-objtp.

    ls_folmem_k-docyr = ls_obj_id-objyr.

    ls_folmem_k-docno = ls_obj_id-objno.

    lv_ep_note        = ls_folmem_k.

    ls_note-objtype   = 'MESSAGE'.

    ls_note-objkey    = lv_ep_note.

    CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT'
      EXPORTING
        obj_rolea    = ls_object
        obj_roleb    = ls_note
        relationtype = 'ATTA'
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      COMMIT WORK .
      WAIT UP TO 1 SECONDS.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc EQ 0
ENDFUNCTION.
