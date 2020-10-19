*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093B_IDOC_COND_A1
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&INCLUDE            :  ZOTCN0093B_IDOC_COND_A1                       *
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
*                                                                     *
* 13-Mar-2015 NSAXENA  E2DK902074 Defect #4846 - This Include has been*
* Copied from another include - ZOTCN0093B_IDOC_COND_A as include     *
* ZOTCN0093B_IDOC_COND_A is having editor lock and cannot be modified *
* or deleted.                                                         *
* For the Defect number 4846 - Field KUNNR is not getting populated at*
* header level                                                        *
*                                                                     *
*16-JUN-2016 RBANERJ1 E1DK918891 Populate new field-KATR1(Attribute 1)*
*                               add in extension Z1OTC_COND_FIELDS    *
*                               with KNA1-KATR1 (Attribute 1) value.  *
*28-Oct-2016 JAHANM  E1DK918891 Defect 5348 - correct KUNNR logic     *
*16-Nov-2016 U033959 E1DK918891 Defect 6632 - pupulate KATR1 field    *
*                                             for A911 table          *
*---------------------------------------------------------------------*
*27-Apr-2017 U033814 E1DK927483 Defect 2666 - Performance Issue in    *
* IDD_0093_Send List Price . The issue is caused by the user exit     *
* when trying add zzbsark for Idoc for ZMAT pricing condition which   *
* Which is no longer required                                         *
*---------------------------------------------------------------------*
*04-Sep-2019 SMUKHER E2DK926429 Defect# 8512 - SCTASK0869067 - Pass   *
*                               Bill To Partys in new field KUNN2 in  *
*                               the Z1OTC_COND_FIELDS segment .       *
*---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&  Include           ZXVKOU03
*&--------------------------------------------------------------------*
" CODE TO FETCH THE FIELD TO PASS TO THE EXTENSION

* Local Constant Declaration
CONSTANTS: lc_cond_a      TYPE edi_mestyp VALUE 'ZOTC_COND_A', " Message Type
           lc_e1komg      TYPE edilsegtyp VALUE 'E1KOMG',      " Segment type
*           lc_e1konh    TYPE edilsegtyp VALUE 'E1KONH',            " Segment type
           lc_segnam      TYPE edilsegtyp VALUE 'Z1OTC_COND_FIELDS', " Segment type
           lc_extension   TYPE edi_cimtyp VALUE 'ZOTCE_COND_A04',    " Extension
           lc_zzbsark     TYPE name_feld  VALUE 'ZZBSARK',           " Field name
* ---> Begin of Change for D3_OTC_IDD_0093 by rbanerj1
           c_enh_idd_0093 TYPE z_enhancement VALUE 'D2_OTC_IDD_0093', " Enhancement No.
           lc_kschl       TYPE name_feld     VALUE 'KSCHL_2',         " Field name
* <--- End of Change for D3_OTC_IDD_0093 by rbanerj1
* ---> Begin of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
           lc_kunag       TYPE char5 VALUE 'KUNAG', " Kunag of type CHAR5
* <--- End of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
* ---> Begin of Insert for D3_OTC_IDD_0093 Defect #6632 by U033959
           lc_kunwe       TYPE char5 VALUE 'KUNWE', " Kunag of type CHAR5
           lc_a911        TYPE char4 VALUE 'A911',  " Table name
* <--- End of Insert for D3_OTC_IDD_0093 Defect #6632 by U033959
           lc_a935        TYPE char4 VALUE 'A935'. " * Defect 5348 by Jahan.

* Local Data Declaration
DATA: lwa_edidd     TYPE edidd,             " Data record (IDoc)
      lwa_e1komg    TYPE e1komg,            " Filter segment with separated condition key
      lwa_condfl    TYPE z1otc_cond_fields, " Cond. ext. fields
      lv_tabname    TYPE char4,             " Tabname of type CHAR4
      lv_bsark      TYPE bsark,             " Customer purchase order type
      lv_tabix      TYPE sytabix,           " Index of Internal Tables
      lv_string     TYPE string,            " Dynamic Where Clause
      lv_string2    TYPE string,            " Dynamic Where Clause
*      lv_flag       TYPE flag,                       " General Flag
      lv_name       TYPE ddobjname,                  " Name of ABAP Dictionary Object
      lv_length     TYPE ddleng,                     " Length (No. of Characters)
      ref_tabletype TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
      ref_rowtype   TYPE REF TO cl_abap_structdescr, " Runtime Type Services
      li_itab       TYPE REF TO data,                " Class
      lwa_itab      TYPE REF TO data,                " Class
      li_fields     TYPE STANDARD TABLE OF dfies,    " Table for Internal Table fields

* ---> Begin of Change for D3_OTC_IDD_0093 by rbanerj1
      lv_katr1      TYPE katr1,                             "Attribute 1
      li_status     TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
      lr_kschl      TYPE RANGE OF kschl,                    " Condition Type
*&--Condition Type(s)
      lwa_kschl     LIKE LINE OF lr_kschl.
* <--- End of Change for D3_OTC_IDD_0093 by rbanerj1


* Local Field Symbol Declaration
FIELD-SYMBOLS: <lfs_itab>   TYPE ANY TABLE, " Dynamic Internal Table
               <lfs_work>   TYPE any,       " Dynamic Workarea
               <lfs_field>  TYPE any,       " Dynamic Field
               <lfs_fields> TYPE dfies,     " DD Interface: Table Fields for DDIF_FIELDINFO_GET
* ---> Begin of Change for D3_OTC_IDD_0093 by rbanerj1
               <lfs_status> TYPE zdev_enh_status, " Enhancement Status
* <--- End of Change for D3_OTC_IDD_0093 by rbanerj1
* ---> Begin of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
               <lfs_edidd>  TYPE edidd. " Data record (IDoc)
* <--- End of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA

*&-- Begin of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
TYPES: BEGIN OF lty_knvp,
       kunnr TYPE kunnr,                                              " Customer Number
       vkorg TYPE vkorg,                                              " Sales Organization
       vtweg TYPE vtweg,                                              " Distribution Channel
       spart TYPE spart,                                              " Division
       parvw TYPE parvw,                                              " Partner Function
       parza TYPE parza,                                              " Partner counter
       kunn2 TYPE kunn2,                                              " Customer number of business partner
       END OF lty_knvp.

DATA: lwa_sales_area TYPE fkk_ranges,                                 " local work area
      li_knvp        TYPE STANDARD TABLE OF lty_knvp INITIAL SIZE 0,  " local internal table
      lv_sales_area  TYPE char10,                                     " local variable
      lr_sales_area  TYPE STANDARD TABLE OF fkk_ranges.               " local range table

CONSTANTS: lc_sales TYPE z_criteria VALUE 'SALES_AREA_DIA',           " EMI criteria
           lc_spart TYPE spart VALUE '00',                            " Division = 00
           lc_re    TYPE parvw VALUE 'RE',                            " RE = Bill To Party
           lc_sep   TYPE char1 VALUE '/'.                             " Slash
*&-- End of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019


* Begin of Defect - 2666
*  The below Code is comented as the D2 code for sending ZZBSARK is no longer required.
* In future if it needs to be activated be careful while buiding the dynamic query  as there
* was huge performance issues with this in D3 Land Scape

*IF message_type = lc_cond_a
.
** Getting the Condition Record Table name
*  LOOP AT idoc_data INTO lwa_edidd
*                    WHERE segnam = lc_e1komg.
*    lwa_e1komg = lwa_edidd-sdata.
*    CONCATENATE   lwa_e1komg-kvewe  lwa_e1komg-kotabnr INTO lv_tabname.
*    EXIT.
*  ENDLOOP. " LOOP AT idoc_data INTO lwa_edidd
*
*  IF lwa_e1komg IS NOT INITIAL AND lv_tabname IS NOT INITIAL.
****>>> Begin of logic for Creation of Dynamic Internal table
*    ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lv_tabname ).
*    ref_tabletype = cl_abap_tabledescr=>create( p_line_type = ref_rowtype ).
*    CREATE DATA li_itab TYPE HANDLE ref_tabletype.
*    CREATE DATA lwa_itab TYPE HANDLE ref_rowtype.
*    ASSIGN li_itab->* TO <lfs_itab>.
*    ASSIGN lwa_itab->* TO <lfs_work>.
****<<< End of Logic for Creation fo Dynamic Internal Table
*
****>>> Begin of building dynamic where clase
*    CLEAR lv_string.
** Adding Application in the where clause
*    IF lwa_e1komg-kappl IS NOT INITIAL.
*      CLEAR lv_string2.
*      CONCATENATE text-001 lwa_e1komg-kappl text-001 INTO lv_string2.
*      CONCATENATE 'KAPPL EQ' lv_string2 INTO lv_string SEPARATED BY space.
*    ENDIF. " IF lwa_e1komg-kappl IS NOT INITIAL
*    IF lv_string IS NOT INITIAL AND lwa_e1komg-kappl IS NOT INITIAL.
*      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
*    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kappl IS NOT INITIAL
*
** Adding Output Type
*    IF lwa_e1komg-kschl IS NOT INITIAL.
*      CLEAR lv_string2.
*      CONCATENATE text-001 lwa_e1komg-kschl text-001 INTO lv_string2.
*      CONCATENATE lv_string 'KSCHL EQ' lv_string2 INTO lv_string SEPARATED BY space.
*    ENDIF. " IF lwa_e1komg-kschl IS NOT INITIAL
*    IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL.
*      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
*    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
*
** Adding Start Date and End Date
*    CLEAR lv_string2.
*    CONCATENATE text-001 sy-datum text-001 INTO lv_string2.
*    CONCATENATE lv_string 'DATBI GE' lv_string2 INTO lv_string SEPARATED BY space.
*    CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
*    CONCATENATE lv_string 'DATAB LE' lv_string2 INTO lv_string SEPARATED BY space.
*    CLEAR lv_string2.
****<<< End of building dynamic where clase
*
*    IF lv_string IS NOT INITIAL.
** Over Here we are doing select * instead of fields because it is a dynamic selection
** However it is possible to get the selection fields dynamically but since the it is condition
** record table so the total number of fields will not be large and the following selection will
** not lead to any performance issues.
*
*      SELECT *
*             FROM (lv_tabname) INTO TABLE <lfs_itab>
*             WHERE (lv_string).
** No need to handle the -ve case as even if the selection fails then also the idoc needs to get
** trigerred.
*      IF sy-subrc = 0.
*        lv_name = lv_tabname.
** Getting the field names of the dynamic table
*        CALL FUNCTION 'DDIF_FIELDINFO_GET'
*          EXPORTING
*            tabname        = lv_name
*          TABLES
*            dfies_tab      = li_fields
*          EXCEPTIONS
*            not_found      = 1
*            internal_error = 2
*            OTHERS         = 3.
** No need to handle the -ve case
*        IF sy-subrc = 0.
*          LOOP AT <lfs_itab> INTO <lfs_work>.
*            IF lwa_e1komg-matnr IS NOT INITIAL.
** No need to sort the internal table by field names as later on we need to calculate Offset
** as we need to retrieve values. If sorted by fieldname then offset calculation will go
** wrong. Also no need for Binary Search as the number of fields will be very less and
** it is condition record table so will not contain much fields.
*              READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname = 'MATNR'.
*              IF sy-subrc = 0.
*                ASSIGN COMPONENT 'MATNR' OF STRUCTURE <lfs_work> TO <lfs_field>.
*                IF lwa_e1komg-matnr <> <lfs_field>.
*                  CONTINUE.
*                ENDIF. " IF lwa_e1komg-matnr <> <lfs_field>
*              ENDIF. " IF sy-subrc = 0
*            ENDIF. " IF lwa_e1komg-matnr IS NOT INITIAL
*            IF lwa_e1komg-vkorg IS NOT INITIAL.
** No need to sort the internal table by field names as later on we need to calculate Offset
** as we need to retrieve values. If sorted by fieldname then offset calculation will go
** wrong. Also no need for Binary Search as the number of fields will be very less and
** it is condition record table so will not contain much fields.
*              READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname = 'VKORG'.
*              IF sy-subrc = 0.
*                ASSIGN COMPONENT 'VKORG' OF STRUCTURE <lfs_work> TO <lfs_field>.
*                IF lwa_e1komg-vkorg <> <lfs_field>.
*                  CONTINUE.
*                ENDIF. " IF lwa_e1komg-vkorg <> <lfs_field>
*              ENDIF. " IF sy-subrc = 0
*            ENDIF. " IF lwa_e1komg-vkorg IS NOT INITIAL
*
*            IF lwa_e1komg-vtweg IS NOT INITIAL.
** No need to sort the internal table by field names as later on we need to calculate Offset
** as we need to retrieve values. If sorted by fieldname then offset calculation will go
** wrong. Also no need for Binary Search as the number of fields will be very less and
** it is condition record table so will not contain much fields.
*              READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname = 'VTWEG'.
*              IF sy-subrc = 0.
*                ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <lfs_work> TO <lfs_field>.
*                IF lwa_e1komg-vtweg <> <lfs_field>.
*                  CONTINUE.
*                ENDIF. " IF lwa_e1komg-vtweg <> <lfs_field>
*              ENDIF. " IF sy-subrc = 0
*            ENDIF. " IF lwa_e1komg-vtweg IS NOT INITIAL
*
** ---> Begin of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
*
** IDoc structure has field name KUNNR but in pricing condition table
** the field name is KUNAG. So, KUNNR is never populated in the IDoc
*            IF <lfs_field> IS ASSIGNED.
*              UNASSIGN <lfs_field>.
*            ENDIF. " IF <lfs_field> IS ASSIGNED
**Since the Kunnr field is not popoulated we have kept a check on the Kuunr field.
*            IF lwa_e1komg-kunnr IS INITIAL.
*              READ TABLE idoc_data ASSIGNING <lfs_edidd> WITH KEY segnam = lc_e1komg.
*              IF sy-subrc EQ 0.
**Read the internal table to check if the KUNAG field data is present or not.
*                READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname  = lc_kunag.
*                IF sy-subrc = 0.
*                  ASSIGN COMPONENT lc_kunag OF STRUCTURE <lfs_work> TO <lfs_field>.
*                  IF <lfs_field> IS ASSIGNED.
*                    lwa_e1komg-kunnr = <lfs_field>.
**-->Start of changes for Defect 5348 by Jahan.
*                    IF lv_tabname EQ lc_a935.
*                      lwa_e1komg-kunnr = lwa_e1komg-vakey+6(10).
*                    ENDIF. " IF lv_tabname EQ lc_a935
**-->End of changes for Defect 5348 by Jahan.
*
** Overwrite the IDoc data with the KUNNR data in Idoc table.
*                    <lfs_edidd>-sdata = lwa_e1komg.
*                  ENDIF. " IF <lfs_field> IS ASSIGNED
** ---> Begin of Insert for D3_OTC_IDD_0093 Defect #6632 by U033959
** Table A911 only has ship to party field, so populate KUNNR with ship to party
*                ELSE.
*                  IF lv_tabname EQ lc_a911.
*                    READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname  = lc_kunwe.
*                    IF sy-subrc IS INITIAL.
*                      ASSIGN COMPONENT lc_kunwe OF STRUCTURE <lfs_work> TO <lfs_field>.
*                      IF <lfs_field> IS ASSIGNED.
*                        lwa_e1komg-kunnr = <lfs_field>.
**    Overwrite the IDoc data with the KUNNR data in Idoc table.
*                        <lfs_edidd>-sdata = lwa_e1komg.
*                      ENDIF. " IF <lfs_field> IS ASSIGNED
*                    ENDIF.
*                  ENDIF.
** <--- End of Insert for D3_OTC_IDD_0093 Defect #6632 by U033959
*                ENDIF. " IF sy-subrc = 0
*              ENDIF. " IF sy-subrc EQ 0
*            ENDIF. " IF lwa_e1komg-kunnr IS INITIAL
*
** <--- End of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
*
*            ASSIGN COMPONENT lc_zzbsark OF STRUCTURE <lfs_work> TO <lfs_field>.
*            IF sy-subrc = 0.
*              lv_bsark = <lfs_field>.
****>>> Logic for checking the Custom field from the Idoc itself.
** No need to sort the internal table by field names as later on we need to calculate Offset
** as we need to retrieve values. If sorted by fieldname then offset calculation will go
** wrong. Also no need for Binary Search as the number of fields will be very less and
** it is condition record table so will not contain much fields.
*              READ TABLE li_fields TRANSPORTING NO FIELDS
*                                   WITH KEY fieldname = 'ZZBSARK'
*                                            keyflag   = abap_true.
*              IF sy-subrc = 0.
*                lv_tabix = sy-tabix - 1.
*                CLEAR lv_length.
** Over here Assumption has been done that the first 3 fields on any condition record
** table will be Client, Application & Condition Type. So no need to calulate the length
** of the first 3 fields as the field length is known.
****>>> The following logic tries to find out the Offset value of the Field BSARK and tries
****>>> to match it with Value passed in VAKEY field of the Idoc
*                LOOP AT li_fields ASSIGNING <lfs_fields> FROM 4 TO lv_tabix.
*                  lv_length = lv_length + <lfs_fields>-leng.
*                ENDLOOP. " LOOP AT li_fields ASSIGNING <lfs_fields> FROM 4 TO lv_tabix
*
*                IF  lwa_e1komg-vakey+lv_length(4) = lv_bsark
*                AND lwa_e1komg-vakey IS NOT INITIAL  .
*                  lwa_condfl-bsark = lv_bsark.
*                ENDIF. " IF lwa_e1komg-vakey+lv_length(4) = lv_bsark
*
*              ELSE. " ELSE -> IF sy-subrc = 0
*                lwa_condfl-bsark = lv_bsark.
*              ENDIF. " IF sy-subrc = 0
*
*              CLEAR lwa_edidd.
*              IF  lwa_condfl-bsark IS NOT INITIAL.
*                lwa_edidd-segnam = lc_segnam.
*                lwa_edidd-sdata = lwa_condfl.
*                READ TABLE idoc_data TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1komg.
*                IF sy-subrc = 0.
*                  lv_tabix = sy-tabix + 1.
*                  INSERT lwa_edidd INTO idoc_data INDEX lv_tabix.
*                  idoc_cimtype = lc_extension.
*                  EXIT.
*                ENDIF. " IF sy-subrc = 0
*              ENDIF. " IF lwa_condfl-bsark IS NOT INITIAL
*            ENDIF. " IF sy-subrc = 0
*          ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>

* ---> Begin of Change for D3_OTC_IDD_0093 by rbanerj1

*          IF lwa_e1komg-kunnr IS NOT INITIAL.
*
*            CLEAR: li_status[].
*            CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*              EXPORTING
*                iv_enhancement_no = c_enh_idd_0093
*              TABLES
*                tt_enh_status     = li_status.
*
**-- Check, if the Enh is active
** 1. If the value is: “X”, the overall Enhancement is active and can
**    proceed further for checks
*            DELETE li_status WHERE active = abap_false.
*            READ TABLE li_status WITH KEY criteria = lc_kschl "KSCHL_2
*                                 TRANSPORTING NO FIELDS.
*            IF sy-subrc = 0.
**-- Collecting the condition types from EMI Tool
*              LOOP AT li_status ASSIGNING <lfs_status>
*                                  WHERE criteria = lc_kschl.
*                lwa_kschl-sign   = <lfs_status>-sel_sign.
*                lwa_kschl-option = <lfs_status>-sel_option.
*                lwa_kschl-low    = <lfs_status>-sel_low.
*                APPEND lwa_kschl TO lr_kschl.
*                CLEAR lwa_kschl.
*              ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
*            ENDIF. " IF sy-subrc = 0
*
*            IF lwa_e1komg-kschl IN lr_kschl.
*
*              CLEAR lv_katr1.
*              SELECT SINGLE katr1 " Attribute 1
*                       FROM kna1  " General Data in Customer Master
*                       INTO lv_katr1
*                      WHERE kunnr = lwa_e1komg-kunnr.
*              IF sy-subrc IS INITIAL AND lv_katr1 IS NOT INITIAL.
*                CLEAR lwa_condfl.
*                IF <lfs_edidd> IS ASSIGNED.
*                  UNASSIGN <lfs_edidd>.
*                ENDIF. " IF <lfs_edidd> IS ASSIGNED
*
*                READ TABLE idoc_data ASSIGNING <lfs_edidd> WITH KEY segnam = lc_segnam. " lc_e1komg.
*                IF sy-subrc IS INITIAL.
*                  lwa_condfl = <lfs_edidd>-sdata. "copy SDATA
*                  lwa_condfl-katr1 = lv_katr1. "Update KATR1
*                  <lfs_edidd>-sdata = lwa_condfl. "Update SDATA
*
*                ELSE. " ELSE -> IF sy-subrc IS INITIAL
*                  CLEAR lwa_edidd.
*                  lwa_condfl-katr1 = lv_katr1. "Update KATR1
*                  lwa_edidd-segnam = lc_segnam.
*                  lwa_edidd-sdata = lwa_condfl.
*                  READ TABLE idoc_data TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1komg.
*                  IF sy-subrc = 0.
*                    CLEAR lv_tabix.
*                    lv_tabix = sy-tabix + 1.
*                    INSERT lwa_edidd INTO idoc_data INDEX lv_tabix.
*                    idoc_cimtype = lc_extension.
*
*                  ENDIF. " IF sy-subrc = 0
*                ENDIF. " IF sy-subrc IS INITIAL
*              ENDIF. " IF sy-subrc IS INITIAL AND lv_katr1 IS NOT INITIAL
*            ENDIF. " IF lwa_e1komg-kschl IN lr_kschl
*          ENDIF. " IF lwa_e1komg-kunnr IS NOT INITIAL
*
** <--- End of Change for D3_OTC_IDD_0093  by rbanerj1
*
*        ENDIF. " IF sy-subrc = 0
*      ENDIF. " IF sy-subrc = 0
*    ENDIF. " IF lv_string IS NOT INITIAL
*  ENDIF. " IF lwa_e1komg IS NOT INITIAL AND lv_tabname IS NOT INITIAL
*ENDIF. " IF message_type = lc_cond_a
* End of Defect - 2666


* Begin of Defect - 2666
* All the code in the User Exit is commented and only D3 Code is copied down

IF message_type = lc_cond_a.
  LOOP AT idoc_data INTO lwa_edidd
                    WHERE segnam = lc_e1komg.
    lwa_e1komg = lwa_edidd-sdata.
    EXIT.
  ENDLOOP. " LOOP AT idoc_data INTO lwa_edidd

  IF lwa_e1komg-kunnr IS NOT INITIAL.

    CLEAR: li_status[].
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = c_enh_idd_0093
      TABLES
        tt_enh_status     = li_status.

*-- Check, if the Enh is active
* 1. If the value is: “X”, the overall Enhancement is active and can
*    proceed further for checks
    DELETE li_status WHERE active = abap_false.
    READ TABLE li_status WITH KEY criteria = lc_kschl "KSCHL_2
                         TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
*-- Collecting the condition types from EMI Tool
      LOOP AT li_status ASSIGNING <lfs_status>
                          WHERE criteria = lc_kschl.
        lwa_kschl-sign   = <lfs_status>-sel_sign.
        lwa_kschl-option = <lfs_status>-sel_option.
        lwa_kschl-low    = <lfs_status>-sel_low.
        APPEND lwa_kschl TO lr_kschl.
        CLEAR lwa_kschl.
      ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
    ENDIF. " IF sy-subrc = 0


*&-- Begin of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
*&-- Populate the Sales Area for which the Bill to Party should be
*    populated in KUNN2.
    LOOP AT li_status ASSIGNING <lfs_status> WHERE criteria = lc_sales.
      lwa_sales_area-sign   = <lfs_status>-sel_sign.
      lwa_sales_area-option = <lfs_status>-sel_option.
      lwa_sales_area-low    = <lfs_status>-sel_low.
      APPEND lwa_sales_area TO lr_sales_area.
      CLEAR: lwa_sales_area.
    ENDLOOP.

    IF lwa_e1komg-vkorg IS NOT INITIAL
      AND lwa_e1komg-vtweg IS NOT INITIAL.

*&-- If the Division is not populated , then we put it '00'
      IF lwa_e1komg-spart IS INITIAL.
        lwa_e1komg-spart = lc_spart.
      ENDIF.

*&-- Concatenate Sales Org , Distribution Channel and Division into one variable .
      CONCATENATE lwa_e1komg-vkorg lwa_e1komg-vtweg lwa_e1komg-spart INTO lv_sales_area SEPARATED BY lc_sep.

*&-- If the Sales area belongs to the EMI entry ,
      IF lv_sales_area IN lr_sales_area.

*&-- We pick the Bill To Party(s) from KNVP based on the customer
*    and corresponding Sales Area
        SELECT  kunnr
                vkorg
                vtweg
                spart
                parvw
                parza
                kunn2
    FROM knvp
    INTO TABLE li_knvp
    WHERE kunnr = lwa_e1komg-kunnr
    AND   vkorg = lwa_e1komg-vkorg
    AND   vtweg = lwa_e1komg-vtweg
    AND   spart = lwa_e1komg-spart
    AND   parvw = lc_re.

        IF sy-subrc IS INITIAL.
          DELETE li_knvp WHERE kunn2 = lwa_e1komg-kunnr.
          SORT li_knvp BY parza DESCENDING.

        ENDIF.
      ENDIF.
    ENDIF.
*&-- End of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019

    IF lwa_e1komg-kschl IN lr_kschl.

      CLEAR lv_katr1.
      SELECT SINGLE katr1 " Attribute 1
               FROM kna1  " General Data in Customer Master
               INTO lv_katr1
              WHERE kunnr = lwa_e1komg-kunnr.
      IF sy-subrc IS INITIAL AND lv_katr1 IS NOT INITIAL.
        CLEAR lwa_condfl.
        IF <lfs_edidd> IS ASSIGNED.
          UNASSIGN <lfs_edidd>.
        ENDIF. " IF <lfs_edidd> IS ASSIGNED

*&-- Begin of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
*&-- If no Bill To Party found then the first KUNN2 should be populated with
* Sold To Party itself.
        IF li_knvp IS INITIAL.  " If no Bill-To Party

            lwa_condfl-kunn2 = lwa_e1komg-kunnr. " Update Bill to Party
*&-- End of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019

          READ TABLE idoc_data ASSIGNING <lfs_edidd> WITH KEY segnam = lc_segnam. " lc_e1komg.
          IF sy-subrc IS INITIAL.
            lwa_condfl = <lfs_edidd>-sdata. "copy SDATA
            lwa_condfl-katr1 = lv_katr1. "Update KATR1
            <lfs_edidd>-sdata = lwa_condfl. "Update SDATA

          ELSE. " ELSE -> IF sy-subrc IS INITIAL
            CLEAR lwa_edidd.
            lwa_condfl-katr1 = lv_katr1. "Update KATR1
            lwa_edidd-segnam = lc_segnam.
            lwa_edidd-sdata = lwa_condfl.
            READ TABLE idoc_data TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1komg.
            IF sy-subrc = 0.
              CLEAR lv_tabix.
              lv_tabix = sy-tabix + 1.
              INSERT lwa_edidd INTO idoc_data INDEX lv_tabix.
              idoc_cimtype = lc_extension.

            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc IS INITIAL

*&-- Begin of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
* If more Bill To Party(s) are populated , then they will be populated in other
* Z1OTC_COND_FIELDS segments as well.
        ELSE.

          LOOP AT li_knvp ASSIGNING FIELD-SYMBOL(<lfs_knvp>).
            CLEAR lwa_edidd.
            lwa_condfl-katr1 = lv_katr1. "Update KATR1
            lwa_condfl-kunn2 = <lfs_knvp>-kunn2. " Update Bill to Party
            lwa_edidd-segnam = lc_segnam.
            lwa_edidd-sdata = lwa_condfl.
*&-- We cannot sort the table IDOC_DATA hence BINARY SEARCH not used.
            READ TABLE idoc_data TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1komg.
            IF sy-subrc = 0.
              CLEAR lv_tabix.
              lv_tabix = sy-tabix + 1.
              INSERT lwa_edidd INTO idoc_data INDEX lv_tabix.
              idoc_cimtype = lc_extension.
            ENDIF.
          ENDLOOP.

*&-- We also need to pass the Sold To Party at the first.
            lwa_condfl-katr1 = lv_katr1. "Update KATR1
            lwa_condfl-kunn2 = lwa_e1komg-kunnr. " Update Bill to Party
            lwa_edidd-segnam = lc_segnam.
            lwa_edidd-sdata = lwa_condfl.
            INSERT lwa_edidd INTO idoc_data INDEX 2.
            CLEAR: lwa_edidd.
            idoc_cimtype = lc_extension.

          IF <lfs_knvp> IS ASSIGNED.
           UNASSIGN: <lfs_knvp>.
          ENDIF.
        ENDIF.
*&-- End of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019

      ENDIF. " IF sy-subrc IS INITIAL AND lv_katr1 IS NOT INITIAL
    ENDIF. " IF lwa_e1komg-kschl IN lr_kschl
  ENDIF. " IF lwa_e1komg-kunnr IS NOT INITIAL
ENDIF. " IF message_type = lc_cond_a

*&-- Begin of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
CLEAR: lv_sales_area,
       lr_sales_area,
       li_knvp.
*&-- End of insert for Defect# 8512 SCTASK0869067 by SMUKHER on 04-Sep-2019
