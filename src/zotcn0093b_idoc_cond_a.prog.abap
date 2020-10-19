*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093B_IDOC_COND_A
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&INCLUDE            :  ZOTCN0093B_IDOC_COND_A                        *
* TITLE              :  Creation of IDOC for message type COND_A      *
* DEVELOPER          :  Moushumi Bhattacharya                         *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION: THis User Exit adds the custom segment into the Idoc   *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-MAY-2014 MBHATTA1 E2DK902074 INITIAL DEVELOPMENT                 *
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZXVKOU03
*&---------------------------------------------------------------------*
" CODE TO FETCH THE FIELD TO PASS TO THE EXTENSION

* Local Constant Declaration
CONSTANTS: lc_cond_a    TYPE edi_mestyp VALUE 'ZOTC_COND_A',       " Message Type
           lc_e1komg    TYPE edilsegtyp VALUE 'E1KOMG',            " Segment type
           lc_e1konh    TYPE edilsegtyp VALUE 'E1KONH',            " Segment type
           lc_segnam    TYPE edilsegtyp VALUE 'Z1OTC_COND_FIELDS', " Segment type
           lc_extension TYPE edi_cimtyp VALUE 'ZOTCE_COND_A04',    " Extension
           lc_zzbsark   TYPE name_feld  VALUE 'ZZBSARK'.           " Field name

* Local Data Declaration
DATA: lwa_edidd     TYPE edidd,                      " Data record (IDoc)
      lwa_e1komg    TYPE e1komg,                     " Filter segment with separated condition key
      lwa_condfl    TYPE z1otc_cond_fields,          " Cond. ext. fields
      lv_tabname    TYPE char4,                      " Tabname of type CHAR4
      lv_bsark      TYPE bsark,                      " Customer purchase order type
      lv_tabix      TYPE sytabix,                    " Index of Internal Tables
      lv_string     TYPE string,                     " Dynamic Where Clause
      lv_string2    TYPE string,                     " Dynamic Where Clause
      lv_flag       TYPE flag,                       " General Flag
      lv_name       TYPE ddobjname,                  " Name of ABAP Dictionary Object
      lv_length     TYPE ddleng,                     " Length (No. of Characters)
      ref_tabletype TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
      ref_rowtype   TYPE REF TO cl_abap_structdescr, " Runtime Type Services
      li_itab       TYPE REF TO data,                " Class
      lwa_itab      TYPE REF TO data,                " Class
      li_fields     TYPE STANDARD TABLE OF dfies.    " Table for Internal Table fields

* Local Field Symbol Declaration
FIELD-SYMBOLS: <lfs_itab>   TYPE ANY TABLE, " Dynamic Internal Table
               <lfs_work>   TYPE any,       " Dynamic Workarea
               <lfs_field>  TYPE any,       " Dynamic Field
               <lfs_fields> TYPE dfies.     " DD Interface: Table Fields for DDIF_FIELDINFO_GET

IF message_type = lc_cond_a.
* Getting the Condition Record Table name
  LOOP AT idoc_data INTO lwa_edidd
                    WHERE segnam = lc_e1komg.
    lwa_e1komg = lwa_edidd-sdata.
    CONCATENATE   lwa_e1komg-kvewe  lwa_e1komg-kotabnr INTO lv_tabname.
    EXIT.
  ENDLOOP. " LOOP AT idoc_data INTO lwa_edidd

  IF lwa_e1komg IS NOT INITIAL AND lv_tabname IS NOT INITIAL.
***>>> Begin of logic for Creation of Dynamic Internal table
    ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lv_tabname ).
    ref_tabletype = cl_abap_tabledescr=>create( p_line_type = ref_rowtype ).
    CREATE DATA li_itab TYPE HANDLE ref_tabletype.
    CREATE DATA lwa_itab TYPE HANDLE ref_rowtype.
    ASSIGN li_itab->* TO <lfs_itab>.
    ASSIGN lwa_itab->* TO <lfs_work>.
***<<< End of Logic for Creation fo Dynamic Internal Table

***>>> Begin of building dynamic where clase
    CLEAR lv_string.
* Adding Application in the where clause
    IF lwa_e1komg-kappl IS NOT INITIAL.
      CLEAR lv_string2.
      CONCATENATE text-001 lwa_e1komg-kappl text-001 INTO lv_string2.
      CONCATENATE 'KAPPL EQ' lv_string2 INTO lv_string SEPARATED BY space.
    ENDIF. " IF lwa_e1komg-kappl IS NOT INITIAL
    IF lv_string IS NOT INITIAL AND lwa_e1komg-kappl IS NOT INITIAL.
      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kappl IS NOT INITIAL

* Adding Output Type
    IF lwa_e1komg-kschl IS NOT INITIAL.
      CLEAR lv_string2.
      CONCATENATE text-001 lwa_e1komg-kschl text-001 INTO lv_string2.
      CONCATENATE lv_string 'KSCHL EQ' lv_string2 INTO lv_string SEPARATED BY space.
    ENDIF. " IF lwa_e1komg-kschl IS NOT INITIAL
    IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL.
      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL

* Adding Start Date and End Date
    CLEAR lv_string2.
    CONCATENATE text-001 sy-datum text-001 INTO lv_string2.
    CONCATENATE lv_string 'DATBI GE' lv_string2 INTO lv_string SEPARATED BY space.
    CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    CONCATENATE lv_string 'DATAB LE' lv_string2 INTO lv_string SEPARATED BY space.
    CLEAR lv_string2.
***<<< End of building dynamic where clase

    IF lv_string IS NOT INITIAL.
* Over Here we are doing select * instead of fields because it is a dynamic selection
* However it is possible to get the selection fields dynamically but since the it is condition
* record table so the total number of fields will not be large and the following selection will
* not lead to any performance issues.
      SELECT *
             FROM (lv_tabname) INTO TABLE <lfs_itab>
             WHERE (lv_string).
* No need to handle the -ve case as even if the selection fails then also the idoc needs to get
* trigerred.
      IF sy-subrc = 0.
        lv_name = lv_tabname.
* Getting the field names of the dynamic table
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = lv_name
          TABLES
            dfies_tab      = li_fields
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
* No need to handle the -ve case
        IF sy-subrc = 0.
          LOOP AT <lfs_itab> INTO <lfs_work>.
            IF lwa_e1komg-matnr IS NOT INITIAL.
* No need to sort the internal table by field names as later on we need to calculate Offset
* as we need to retrieve values. If sorted by fieldname then offset calculation will go
* wrong. Also no need for Binary Search as the number of fields will be very less and
* it is condition record table so will not contain much fields.
              READ TABLE li_fields TRANSPORTING NO FIELDS
                                   WITH KEY fieldname = 'MATNR'.
              IF sy-subrc = 0.
                ASSIGN COMPONENT 'MATNR' OF STRUCTURE <lfs_work> TO <lfs_field>.
                IF lwa_e1komg-matnr <> <lfs_field>.
                  CONTINUE.
                ENDIF. " IF lwa_e1komg-matnr <> <lfs_field>
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF lwa_e1komg-matnr IS NOT INITIAL
            IF lwa_e1komg-vkorg IS NOT INITIAL.
* No need to sort the internal table by field names as later on we need to calculate Offset
* as we need to retrieve values. If sorted by fieldname then offset calculation will go
* wrong. Also no need for Binary Search as the number of fields will be very less and
* it is condition record table so will not contain much fields.
              READ TABLE li_fields TRANSPORTING NO FIELDS
                                   WITH KEY fieldname = 'VKORG'.
              IF sy-subrc = 0.
                ASSIGN COMPONENT 'VKORG' OF STRUCTURE <lfs_work> TO <lfs_field>.
                IF lwa_e1komg-vkorg <> <lfs_field>.
                  CONTINUE.
                ENDIF. " IF lwa_e1komg-vkorg <> <lfs_field>
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF lwa_e1komg-vkorg IS NOT INITIAL
            IF lwa_e1komg-vtweg IS NOT INITIAL.
* No need to sort the internal table by field names as later on we need to calculate Offset
* as we need to retrieve values. If sorted by fieldname then offset calculation will go
* wrong. Also no need for Binary Search as the number of fields will be very less and
* it is condition record table so will not contain much fields.
              READ TABLE li_fields TRANSPORTING NO FIELDS
                                   WITH KEY fieldname = 'VTWEG'.
              IF sy-subrc = 0.
                ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <lfs_work> TO <lfs_field>.
                IF lwa_e1komg-vtweg <> <lfs_field>.
                  CONTINUE.
                ENDIF. " IF lwa_e1komg-vtweg <> <lfs_field>
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF lwa_e1komg-vtweg IS NOT INITIAL
            ASSIGN COMPONENT lc_zzbsark OF STRUCTURE <lfs_work> TO <lfs_field>.
            IF sy-subrc = 0.
              lv_bsark = <lfs_field>.
***>>> Logic for checking the Custom field from the Idoc itself.
* No need to sort the internal table by field names as later on we need to calculate Offset
* as we need to retrieve values. If sorted by fieldname then offset calculation will go
* wrong. Also no need for Binary Search as the number of fields will be very less and
* it is condition record table so will not contain much fields.
              READ TABLE li_fields TRANSPORTING NO FIELDS
                                   WITH KEY fieldname = 'ZZBSARK'
                                            keyflag   = abap_true.
              IF sy-subrc = 0.
                lv_tabix = sy-tabix - 1.
                CLEAR lv_length.
* Over here Assumption has been done that the first 3 fields on any condition record
* table will be Client, Application & Condition Type. So no need to calulate the length
* of the first 3 fields as the field length is known.
***>>> The following logic tries to find out the Offset value of the Field BSARK and tries
***>>> to match it with Value passed in VAKEY field of the Idoc
                LOOP AT li_fields ASSIGNING <lfs_fields> FROM 4 TO lv_tabix.
                  lv_length = lv_length + <lfs_fields>-leng.
                ENDLOOP. " LOOP AT li_fields ASSIGNING <lfs_fields> FROM 4 TO lv_tabix

                IF  lwa_e1komg-vakey+lv_length(4) = lv_bsark
                AND lwa_e1komg-vakey IS NOT INITIAL  .
                  lwa_condfl-bsark = lv_bsark.
                ENDIF. " IF lwa_e1komg-vakey+lv_length(4) = lv_bsark

              ELSE. " ELSE -> IF lwa_e1komg-vakey+lv_length(4) = lv_bsark
                lwa_condfl-bsark = lv_bsark.
              ENDIF. " IF sy-subrc = 0

              CLEAR lwa_edidd.
              IF  lwa_condfl-bsark IS NOT INITIAL.
                lwa_edidd-segnam = lc_segnam.
                lwa_edidd-sdata = lwa_condfl.
                READ TABLE idoc_data TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1komg.
                IF sy-subrc = 0.
                  lv_tabix = sy-tabix + 1.
                  INSERT lwa_edidd INTO idoc_data INDEX lv_tabix.
                  idoc_cimtype = lc_extension.
                  EXIT.
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF lwa_condfl-bsark IS NOT INITIAL
            ENDIF. " IF sy-subrc = 0
          ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>
        ENDIF. " if sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lv_string IS NOT INITIAL
  ENDIF. " IF lwa_e1komg IS NOT INITIAL AND lv_tabname IS NOT INITIAL
ENDIF. " IF message_type = lc_cond_a
