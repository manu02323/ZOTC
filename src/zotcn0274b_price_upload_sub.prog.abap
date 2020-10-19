*&---------------------------------------------------------------------*
*&  Include           ZOTCN0274B_PRICE_UPLOAD_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274   (Part 1)                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*  26-Oct-2015 DMOIRAN  E2DK913959 Defect 1209 PGL B development.      *
* To support pricing condition text upload changes done in excel       *
* upload to allow 72 characters field                                  *
*&---------------------------------------------------------------------*
*01-Dec-2015   VCHOUDH  E2DK916237  Defect 1264.
*Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so, then if there is no negative sign in the
* value it will be converted to negative value
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*       Check File path is valid or not
*----------------------------------------------------------------------*
*      -->FP_P_PFILE  text
*----------------------------------------------------------------------*
FORM f_check_file  USING  fp_p_pfile TYPE localfile. " Local file for upload/download

* Check Whether File Path is valid or not
  PERFORM f_validate_p_file USING fp_p_pfile.
  CLEAR gv_extn.
* Check file extension for text file
  PERFORM f_file_extn_check USING fp_p_pfile
                            CHANGING gv_extn.
* Convert the Extension to Upper case
  TRANSLATE gv_extn TO UPPER CASE.
  IF gv_extn <> c_extn1 AND
    gv_extn <> c_extn.
    MESSAGE i968(zotc_msg) DISPLAY LIKE c_e. " Please provide Excel file format Only
    LEAVE LIST-PROCESSING.
  ENDIF. " IF gv_extn <> c_extn1 AND

ENDFORM. " F_CHECK_FILE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_AND_VALIDATION
*&---------------------------------------------------------------------*
*       Upload and Validation
*----------------------------------------------------------------------*
*      -->FP_P_PFILE File path
*----------------------------------------------------------------------*
FORM f_upload_and_validation  USING  fp_p_pfile TYPE localfile. " Local file for upload/download

* Local Constant Declaration
  CONSTANTS:
      lc_beg          TYPE i            VALUE '1',    " Beg of type Integers
      lc_ecol         TYPE i            VALUE '256',  " Ecol of type Integers
      lc_erow         TYPE i            VALUE '9999', " Erow of type Integers
      lc_1st_row      TYPE kcd_ex_row_n VALUE '0001', " Flexible Excel upload: row number
      lc_2nd_row      TYPE kcd_ex_row_n VALUE '0002'. " Flexible Excel upload: row number

* Local Data Declaration
  DATA:
       li_intern      TYPE ty_t_intern,
       li_intern_tmp  TYPE ty_t_intern,
       lwa_component  TYPE cl_abap_structdescr=>component,
       lref_line_type TYPE REF TO cl_abap_structdescr, " Runtime Type Services
       lref_tab       TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
       lref_dyn_tab   TYPE REF TO data,                "  class
       lref_dyn_wa    TYPE REF TO data,                "  class
       lref_dyn_tab_s TYPE REF TO data,                "  class
       lref_dyn_tabtmp TYPE REF TO data,               "  class
       lref_type      TYPE REF TO cl_abap_typedescr,   " Runtime Type Services
       lv_field       TYPE fieldname,                  " Field Name
       lv_field_de    TYPE rollname,                   " Data element (semantic domain)
       lv_index       TYPE i,                          " Index of type Integers
       lv_count1      TYPE i,                          " Count1 of type Integers
       lv_kbetr1_col TYPE i,                           " Kbetr1_col of type Integers
       lv_konwa_col TYPE i ,                           " Konwa_col of type Integers
       lv_kotabnr_col   TYPE i,                        " Kotabnr_col of type Integers
       lv_no_cust_g1  TYPE char1,                      " No_cust_g1 of type CHAR1
        lv_no_cust_g2  TYPE char1,                     " No_cust_g2 of type CHAR1
        lv_tab TYPE char5,                             " Tab of type CHAR5
       lv_row_no      TYPE sytabix,                    " Index of Internal Tables
       lv_field_ctab      TYPE fieldname,              " Field Name
       lv_ent         TYPE sytabix,                    " Index of Internal Tables
       lv_ctype       TYPE kschl,
       lv_ctab        TYPE kotabnr,                    " Condition table
       lv_fcondtab    TYPE tabname.                    " Table Name

  DATA :  lwa_row TYPE REF TO cl_abap_structdescr, " Runtime Type Services
        li_component_temp TYPE cl_abap_structdescr=>component_table.

*---> Begin of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
  CONSTANTS : lc_field TYPE char10 VALUE 'KBETR',      " Field of type CHAR10
              lc_kbetr1 TYPE char10 VALUE 'KBETR1',    " Kbetr1 of type CHAR10
              lc_konwa TYPE char10 VALUE 'KONWA',      " Konwa of type CHAR10
              lc_kotabnr TYPE char10 VALUE 'KOTABNR',  " Kotabnr of type CHAR10
              lc_zzkvgr1  TYPE char10 VALUE 'ZZKVGR1', " Zzkvgr1 of type CHAR10
              lc_zzkvgr2  TYPE char10 VALUE 'ZZKVGR2'. " Zzkvgr2 of type CHAR10
  DATA : lv_subset TYPE char1. " Subset of type CHAR1
*<--- End of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.

*--> Begin of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.
  CONSTANTS : lc_kschl  TYPE fieldname VALUE 'KSCHL',   " Kschl of type CHAR10
              lc_kappl  TYPE kappl VALUE 'V',           " Application
              lc_row_03 TYPE kcd_ex_row_n VALUE '0003'. " Row_03 of type CHAR4

  DATA :  lv_kschl_col TYPE kcd_ex_col_n , " Kschl_col of type Integers
          lv_knega     TYPE knega.         " Plus/minus sign of the condition amount
*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH

* Local Field Symbol
  FIELD-SYMBOLS :
* ---> Begin of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
*      <lfs_intern>      TYPE alsmex_tabline,        " Rows for Table with Excel Data
*      <lfs_intern_temp> TYPE alsmex_tabline,        " Rows for Table with Excel Data

      <lfs_intern>      TYPE zotc_s_alsmex_tabline, " Rows for Table with Excel Data
      <lfs_intern_temp> TYPE zotc_s_alsmex_tabline, " Rows for Table with Excel Data
* <--- End    of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
      <lfs_field_val>   TYPE any.

* Uploading the file from Presentation server
* ---> Begin of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN

*  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*    EXPORTING
*      filename                = fp_p_pfile
*      i_begin_col             = lc_beg
*      i_begin_row             = lc_beg
*      i_end_col               = lc_ecol
*      i_end_row               = lc_erow
*    TABLES
*      intern                  = li_intern
*    EXCEPTIONS
*      inconsistent_parameters = 1
*      upload_ole              = 2
*      OTHERS                  = 3.

  CALL FUNCTION 'ZOTC_ALSM_EXCEL_TO_INT_TABLE'
    EXPORTING
      filename                = fp_p_pfile
      i_begin_col             = lc_beg
      i_begin_row             = lc_beg
      i_end_col               = lc_ecol
      i_end_row               = lc_erow
    TABLES
      intern                  = li_intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

* <--- End    of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
  IF sy-subrc <> 0.
    MESSAGE i967(zotc_msg) WITH fp_p_pfile DISPLAY LIKE c_e. " Error in opening the file &
    LEAVE LIST-PROCESSING.

  ELSE. " ELSE -> IF sy-subrc <> 0

* Make a temp table Li_intern_tmp
    APPEND LINES OF li_intern TO li_intern_tmp.
* First Row is having header information. So, to read the header information
* keep first row and delete others row
    DELETE li_intern_tmp WHERE row NE lc_1st_row.

    IF li_intern_tmp[] IS NOT INITIAL.
      CLEAR : lv_count1.
      LOOP AT li_intern_tmp ASSIGNING <lfs_intern>.
        CLEAR lwa_component.
        SPLIT <lfs_intern>-value AT c_fslash INTO lv_field lv_field_de.

        SHIFT lv_field LEFT DELETING LEADING space.
        TRANSLATE lv_field TO UPPER CASE.
        SHIFT lv_field_de LEFT DELETING LEADING space.

*--> Begin of Insert for D2_OTC_EDD_0274/Defect 1264 by vchoudh.
**  For condition table
        IF lv_field = lc_kotabnr.
          lv_kotabnr_col = <lfs_intern>-col.
        ENDIF. " IF lv_field = lc_kotabnr

        IF lv_field = lc_kschl.
          lv_kschl_col = <lfs_intern>-col.
        ENDIF. " IF lv_field = lc_kschl

*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.


*---> Begin of Insert for D2_OTC_EDD_0274/Defect 959 By VCHOUDH.
**        For field KBETR .
        IF lv_field = lc_field.
          lv_count1 = <lfs_intern>-col.
        ENDIF. " IF lv_field = lc_field
**      for Field KBETR1.
        IF lv_field = lc_kbetr1.
          lv_kbetr1_col = <lfs_intern>-col.
        ENDIF. " IF lv_field = lc_kbetr1
**     for field KONWA.
        IF lv_field = lc_konwa.
          lv_konwa_col = <lfs_intern>-col.
        ENDIF. " IF lv_field = lc_konwa
*<--- End of Insert for D2_OTC_EDD_0274/Defect 959 ByVCHOUDH.
************ i_ntype table will be used for write file to application
        wa_ntype-name = lv_field.
        wa_ntype-ty = lv_field_de.
        APPEND wa_ntype TO i_ntype.
        CLEAR wa_ntype.
************
* Field name
        lwa_component-name = lv_field.
* Field Type
        CALL METHOD cl_abap_datadescr=>describe_by_name
          EXPORTING
            p_name         = lv_field_de
          RECEIVING
            p_descr_ref    = lref_type
          EXCEPTIONS
            type_not_found = 1
            OTHERS         = 2.
        IF sy-subrc IS INITIAL.
          lwa_component-type ?= lref_type.
          CLEAR lref_type.
        ELSE. " ELSE -> IF sy-subrc IS INITIAL
          MESSAGE i971(zotc_msg) WITH fp_p_pfile DISPLAY LIKE c_e. " Please enter Fieldname/Fieldtype correctly in file &.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF sy-subrc IS INITIAL

        APPEND lwa_component TO i_component.
        CLEAR lwa_component.
      ENDLOOP. " LOOP AT li_intern_tmp ASSIGNING <lfs_intern>

*--> Begin of addition for D2_OTC_EDD_0274 BY VCHOUDH.
      CLEAR : lv_no_cust_g1,
              lv_no_cust_g2.
      READ TABLE li_intern ASSIGNING <lfs_intern> WITH KEY row = lc_row_03
                                                           col = lv_kotabnr_col.
      IF sy-subrc = 0.
        IF <lfs_intern> IS ASSIGNED .

*--> Begin of Insert for D2_OTC_EDD_0274/Defect 1264 By VCHOUDH.
*In Excel to put preceding 0 (zero), inverted comman (') is used.
*But if the value has only digit then inverted comma is not stored in the value.
* And for alphanumeric (eg, 012A) inverted comma is stored in the value.
* So, before removing the preceding comma check if it is there in the
*value or not as the first character
          CLEAR lv_subset.
          lv_subset = <lfs_intern>-value+0(1).
          IF lv_subset CP ''''.
            REPLACE FIRST OCCURRENCE OF '''' IN <lfs_intern>-value WITH space.
            SHIFT <lfs_intern>-value LEFT DELETING LEADING space.
          ENDIF. " IF lv_subset CP ''''
          CONCATENATE 'A' <lfs_intern>-value INTO lv_tab.
*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.

*--> Begin of Delete for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.
*          CONCATENATE 'A' <lfs_intern>-value+1(3) INTO lv_tab.
*<-- End of Delete for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.

          CONDENSE lv_tab.

*  Get Structure of the table "   Condition table .
          lwa_row ?= cl_abap_typedescr=>describe_by_name( p_name = lv_tab ).


          IF lwa_row IS NOT INITIAL.
            li_component_temp = lwa_row->get_components( ).
          ENDIF. " IF lwa_row IS NOT INITIAL

          CLEAR lwa_component.
          READ TABLE li_component_temp INTO lwa_component WITH KEY name = lc_zzkvgr1.
          IF sy-subrc IS NOT INITIAL.
            lv_no_cust_g1 = abap_true.
          ENDIF. " IF sy-subrc IS NOT INITIAL

          CLEAR lwa_component.
          READ TABLE li_component_temp INTO lwa_component WITH KEY name = lc_zzkvgr2.
          IF sy-subrc IS NOT INITIAL.
            lv_no_cust_g2 = abap_true.
          ENDIF. " IF sy-subrc IS NOT INITIAL

        ENDIF. " IF <lfs_intern> IS ASSIGNED
      ENDIF. " IF sy-subrc = 0
*<-- End of addition for D2_OTC_EDD_0274 by VCHOUDH.




************* Dynamic Table Creation Start
*  Create structure of the dynamic internal table.
      CLEAR lref_line_type.
      TRY .
          lref_line_type = cl_abap_structdescr=>create(
                              p_components = i_component
                              p_strict = cl_abap_structdescr=>false ).
        CATCH cx_sy_struct_creation .
          MESSAGE i953(zotc_msg) DISPLAY LIKE c_e. " Dynamic Internal Structure can not be built.
          LEAVE LIST-PROCESSING.
      ENDTRY.
* Create dynamic table with the structure lref_line_type
      IF lref_line_type IS NOT INITIAL.
        CLEAR lref_tab.
        TRY.
            lref_tab = cl_abap_tabledescr=>create( p_line_type  = lref_line_type ).
          CATCH cx_sy_table_creation.
            MESSAGE i953(zotc_msg) DISPLAY LIKE c_e. " Dynamic Internal Structure can not be built.
        ENDTRY.
      ENDIF. " IF lref_line_type IS NOT INITIAL

      IF lref_tab IS NOT INITIAL.
        CREATE DATA lref_dyn_tab TYPE HANDLE lref_tab. " Internal ID of an object
* For Success record
        CREATE DATA lref_dyn_tab_s TYPE HANDLE lref_tab. " Internal ID of an object
* For Temp use
        CREATE DATA lref_dyn_tabtmp TYPE HANDLE lref_tab. " Internal ID of an object
      ENDIF. " IF lref_tab IS NOT INITIAL

      IF lref_line_type IS NOT INITIAL.
        CREATE DATA lref_dyn_wa TYPE HANDLE lref_line_type. " Internal ID of an object
      ENDIF. " IF lref_line_type IS NOT INITIAL

      ASSIGN lref_dyn_tab->* TO <fs_dyn_tab>.
      ASSIGN lref_dyn_wa->* TO <fs_dyn_wa>.

* For Success record
      ASSIGN lref_dyn_tab_s->* TO <fs_dyn_tab_s>.
* For temp use
      ASSIGN lref_dyn_tabtmp->* TO <fs_dyn_tabtmp>.

************* Dynamic Table Creation End

*--> Begin of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH
*Fetch the pricing condition type - discount type T685A-KNEGA = 'X'.
      CLEAR : lv_knega.
      READ TABLE li_intern ASSIGNING <lfs_intern> WITH KEY row = lc_row_03
                                                           col = lv_kschl_col.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE
               knega " Plus/minus sign of the condition amount
          FROM t685a " Conditions: Types: Additional Price Element Data
          INTO lv_knega
          WHERE kappl = lc_kappl
          AND   kschl = <lfs_intern>-value.
      ENDIF. " IF sy-subrc IS INITIAL

*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.


      CLEAR li_intern_tmp[].
      APPEND LINES OF li_intern TO li_intern_tmp.

* To read the data records, first delete the two rows from file(which are having
* Header and description and then start reading others rows
      DELETE li_intern_tmp WHERE row = lc_1st_row
                              OR row = lc_2nd_row.

      IF li_intern_tmp IS NOT INITIAL.

        SORT li_intern_tmp BY row col.

        LOOP AT li_intern_tmp ASSIGNING <lfs_intern>.
          MOVE <lfs_intern>-col TO lv_index.
* To get the field name from i_component table
          READ TABLE i_component ASSIGNING <fs_component> INDEX lv_index.
          IF sy-subrc  IS INITIAL.
* Field name
            lv_field  = <fs_component>-name.
            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_dyn_wa> TO <lfs_field_val>.
            IF <lfs_field_val> IS ASSIGNED.
* Field Value
*---> Begin of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
              IF lv_field = lc_zzkvgr1 AND lv_no_cust_g1 = abap_true.
                CLEAR <lfs_intern>-value.
              ENDIF. " IF lv_field = lc_zzkvgr1 AND lv_no_cust_g1 = abap_true

              IF lv_field = lc_zzkvgr2 AND lv_no_cust_g2 = abap_true.
                CLEAR <lfs_intern>-value.
              ENDIF. " IF lv_field = lc_zzkvgr2 AND lv_no_cust_g2 = abap_true
*  value for field kbetr should be multiply by 10.
              IF lv_index = lv_count1 AND <lfs_intern>-value <> '0.00'.

*--> Begin of insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH
*Check if the pricing condition type is of discount type T685A-KNEGA = 'X'.
*If so, then if there is no negative sign in the value it will be converted to negative value*
                IF lv_knega = abap_true.
                  IF <lfs_intern>-value NS '-'.
                    <lfs_intern>-value = 0 - <lfs_intern>-value.
                  ENDIF. " If <lfs_intern>-value NS '-'
                ENDIF. " IF lv_knega = abap_true
*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.

                UNASSIGN <lfs_intern_temp>.
                READ TABLE li_intern_tmp ASSIGNING <lfs_intern_temp> WITH KEY  row = <lfs_intern>-row
                                                                               col = lv_konwa_col.
                IF sy-subrc IS INITIAL .
                  IF <lfs_intern_temp>-value CP '%'.
                    <lfs_intern>-value = <lfs_intern>-value * 10.
                  ENDIF. " IF <lfs_intern_temp>-value CP '%'
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF lv_index = lv_count1 AND <lfs_intern>-value <> '0 00'

*              value for kbetr1.

              IF lv_index = lv_kbetr1_col AND <lfs_intern>-value <> '0.00'.

*--> Begin of insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH
*Check if the pricing condition type is of discount type T685A-KNEGA = 'X'.
*If so, then if there is no negative sign in the value it will be converted to negative value*
                IF lv_knega = abap_true.
                  IF <lfs_intern>-value NS '-'.
                    <lfs_intern>-value = 0 - <lfs_intern>-value.
                  ENDIF. " If <lfs_intern>-value NS '-'
                ENDIF. " IF lv_knega = abap_true
*<-- End of Insert for D2_OTC_EDD_0274/Defect 1264 by VCHOUDH.

                UNASSIGN <lfs_intern_temp>.
                READ TABLE li_intern_tmp ASSIGNING <lfs_intern_temp> WITH KEY  row = <lfs_intern>-row
                                                                               col = lv_konwa_col.
                IF sy-subrc IS INITIAL .
                  IF <lfs_intern_temp>-value CP '%'.
                    <lfs_intern>-value = <lfs_intern>-value * 10.
                  ENDIF. " IF <lfs_intern_temp>-value CP '%'
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF lv_index = lv_kbetr1_col AND <lfs_intern>-value <> '0 00'


              CLEAR lv_subset.
              lv_subset = <lfs_intern>-value+0(1).
              IF lv_subset CP ''''.
                REPLACE FIRST OCCURRENCE OF '''' IN <lfs_intern>-value WITH space.
                SHIFT <lfs_intern>-value LEFT DELETING LEADING space.
              ENDIF. " IF lv_subset CP ''''
*<--- End of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.

*---> Begin of change for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
              IF lv_index = lv_konwa_col AND <lfs_intern>-value CP '%'.
              ELSE. " ELSE -> IF lv_index = lv_konwa_col AND <lfs_intern>-value CP '%'
                <lfs_field_val> = <lfs_intern>-value.
              ENDIF. " IF lv_index = lv_konwa_col AND <lfs_intern>-value CP '%'
*<--- End of change for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
*<lfs_field_val> = <lfs_intern>-value.

            ENDIF. " IF <lfs_field_val> IS ASSIGNED
          ENDIF. " IF sy-subrc IS INITIAL
* At the end of row number append the value to table <fs_dyn_tab>
          AT END OF row.
            APPEND <fs_dyn_wa> TO <fs_dyn_tab>.
            CLEAR : <fs_dyn_wa>.
          ENDAT.
          CLEAR:  lv_field,
                  lv_index.
        ENDLOOP. " LOOP AT li_intern_tmp ASSIGNING <lfs_intern>

      ELSE. " ELSE -> IF lv_subset CP ''''
        MESSAGE i966(zotc_msg) DISPLAY LIKE c_e. " No records found in input file,Please check the file.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF li_intern_tmp IS NOT INITIAL

    ELSE. " ELSE -> IF <lfs_intern_temp>-value CP '%'
      MESSAGE i966(zotc_msg) DISPLAY LIKE c_e. " No records found in input file,Please check the file.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF li_intern_tmp[] IS NOT INITIAL

  ENDIF. " IF sy-subrc <> 0

* Header information is now in the table i_component and all data is in
*  internal table <fs_dyn_tab>
* Start Validation of data

  IF <fs_dyn_tab> IS ASSIGNED.
*************** Validation of Condition Type***************
* Make a temp table for further use
    APPEND LINES OF <fs_dyn_tab> TO <fs_dyn_tabtmp>.

* get fieldname 'ZCOUNTER'
    lv_index = 2.
    READ TABLE i_component ASSIGNING <fs_component> INDEX lv_index.
    IF sy-subrc IS   INITIAL.
      lv_field = <fs_component>-name.
    ENDIF. " IF sy-subrc IS INITIAL

* Deleting records which are having cZCOUNTER value 1
    LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>.
      ASSIGN COMPONENT lv_field OF STRUCTURE <fs_dyn_wa> TO <lfs_field_val>.
      IF <lfs_field_val> EQ '1'.
        DELETE TABLE <fs_dyn_tabtmp> FROM <fs_dyn_wa>.
      ENDIF. " IF <lfs_field_val> EQ '1'
    ENDLOOP. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>

    CLEAR : lv_field.

* Read field name "KSCHL"
    lv_index = 3.
    READ TABLE i_component ASSIGNING <fs_component> INDEX lv_index.
    IF sy-subrc IS   INITIAL.
      lv_field = <fs_component>-name.
    ENDIF. " IF sy-subrc IS INITIAL

* Read Field name "KOTABNR"
    lv_index = 4.
    READ TABLE i_component ASSIGNING <fs_component> INDEX lv_index.
    IF sy-subrc IS   INITIAL.
      lv_field_ctab = <fs_component>-name.
    ENDIF. " IF sy-subrc IS INITIAL

* Sort table on the basis of KSCHL and KOTABNR, and delete adjacent duplicate
* to find the combination of condition tye and table
    SORT <fs_dyn_tabtmp> BY (lv_field) (lv_field_ctab).
    DELETE ADJACENT DUPLICATES FROM <fs_dyn_tabtmp> COMPARING (lv_field) (lv_field_ctab).
    IF <fs_dyn_tabtmp> IS NOT INITIAL.
      DESCRIBE TABLE <fs_dyn_tabtmp> LINES lv_ent.

      IF lv_ent GT 1.
        MESSAGE i965(zotc_msg) WITH lv_field lv_field_ctab  DISPLAY LIKE c_e. " Please provide only one condition type & and table & in file
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF lv_ent GT 1

        READ TABLE <fs_dyn_tabtmp> ASSIGNING <fs_dyn_wa> INDEX lv_ent.
        IF sy-subrc = 0.
          ASSIGN COMPONENT  lv_field OF STRUCTURE <fs_dyn_wa> TO <lfs_field_val>.
          lv_ctype = <lfs_field_val>.

*************** To find condition table ***************
          PERFORM f_fetch_cond_tab USING lv_ctype
                                   CHANGING i_t682i_r.

          ASSIGN COMPONENT lv_field_ctab OF STRUCTURE <fs_dyn_wa> TO <lfs_field_val>.
          IF <lfs_field_val> NOT IN i_t682i_r.

            MESSAGE i964(zotc_msg) WITH lv_ctab DISPLAY LIKE c_e. " Invalid value & of condition table in file.
            LEAVE LIST-PROCESSING.
          ELSE. " ELSE -> IF <lfs_field_val> NOT IN i_t682i_r
**************** Validation of condition table
            lv_ctab = <lfs_field_val>.

            CONCATENATE c_kvewe lv_ctab INTO lv_fcondtab.

            APPEND LINES OF <fs_dyn_tab> TO <fs_dyn_tab_s>.
* Validation for field value with mandatory fields
* Find check table and field name
            PERFORM f_fields_acc_cond USING lv_fcondtab.

*************** Validation of Table Indicator***************

            lv_index = 1.
* Get the field name from table i_component at index 1
            READ TABLE i_component ASSIGNING <fs_component> INDEX lv_index.
            IF sy-subrc IS   INITIAL.
              lv_field = <fs_component>-name.
            ENDIF. " IF sy-subrc IS INITIAL

            LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>.
              lv_row_no = sy-tabix.
              ASSIGN COMPONENT lv_field OF STRUCTURE <fs_dyn_wa> TO <lfs_field_val>.
              IF <lfs_field_val> EQ space.
                DELETE  <fs_dyn_tab_s> INDEX lv_row_no.

                wa_ereport-msgtyp = c_e.
                wa_ereport-msgtxt = 'Table indicator is blank in file'(002).
                wa_ereport-value = lv_row_no.
                APPEND wa_ereport TO i_ereport.
                CLEAR wa_ereport.
              ENDIF. " IF <lfs_field_val> EQ space
            ENDLOOP. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>
            CLEAR : lv_index, lv_field.

          ENDIF. " IF <lfs_field_val> NOT IN i_t682i_r
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_ent GT 1
      CLEAR: lv_field,lv_field_ctab, <fs_dyn_tabtmp>.

    ENDIF. " IF <fs_dyn_tabtmp> IS NOT INITIAL
  ELSE. " ELSE -> IF <lfs_field_val> EQ space
    MESSAGE i961(zotc_msg) DISPLAY LIKE c_e. " No valid records found in the file
    LEAVE LIST-PROCESSING.
  ENDIF. " IF <fs_dyn_tab> IS ASSIGNED

ENDFORM. " F_UPLOAD_AND_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_COND_TAB
*&---------------------------------------------------------------------*
*       Condition table validation
*----------------------------------------------------------------------*
*      -->P_LV_CTYPE  condition type
*      <--P_LV_CTTAB  condition table
*----------------------------------------------------------------------*
FORM f_fetch_cond_tab  USING    fp_ctype TYPE kschl
                       CHANGING  fp_i_t682i_r TYPE ty_t_t682i_r. " Condition table

  CONSTANTS:
  lc_kappl  TYPE kappl VALUE 'V',   " Application
  lc_sign   TYPE sign   VALUE 'I',  " Debit/Credit Sign (+/-)
  lc_option TYPE option VALUE 'EQ'. " Option for ranges tables

  TYPES:
   BEGIN OF lty_t685,
    kvewe    TYPE t685-kvewe, " Usage of the condition table
    kappl    TYPE t685-kappl, " Application
    kschl    TYPE t685-kschl, " Condition Type
    kozgf    TYPE t685-kozgf, " Access sequence
   END OF lty_t685,

      BEGIN OF lty_t682i,
    kappl TYPE kappl ,        " Application
    kozgf TYPE  kozgf,        " Access sequence
    kolnr TYPE kolnr,         " Access sequence - Access number
    kotabnr TYPE kotabnr,     " Condition table
    END OF lty_t682i.

  DATA : lwa_t685    TYPE lty_t685,
         li_t682i    TYPE STANDARD TABLE OF lty_t682i,
         lwa_t682i_r TYPE ty_t682i_r.

  FIELD-SYMBOLS :  <lfs_t682i> TYPE lty_t682i.
* Fetch data from T685 table
  SELECT SINGLE
      kvewe   " Usage of the condition table
      kappl   " Application
      kschl   " Condition Type
      kozgf   " Access sequence
    FROM t685 " Conditions: Types
    INTO lwa_t685
   WHERE
       kvewe = c_kvewe AND
       kappl = lc_kappl AND
       kschl = fp_ctype.
  IF sy-subrc IS INITIAL.

    SELECT
      kappl     " Application
      kozgf     " Access sequence
      kolnr     " Access sequence - Access number
      kotabnr   " Condition table
     FROM t682i " Conditions: Access Sequences (Generated Form)
     INTO TABLE li_t682i
     WHERE kvewe = lwa_t685-kvewe
       AND kappl = lwa_t685-kappl
       AND kozgf = lwa_t685-kozgf.
    IF sy-subrc  IS NOT INITIAL.

      MESSAGE i957(zotc_msg) WITH fp_ctype DISPLAY LIKE c_e. " No condition table is maintained corresponding to condition type &
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

      LOOP AT li_t682i ASSIGNING <lfs_t682i>.
        lwa_t682i_r-sign   = lc_sign.
        lwa_t682i_r-option = lc_option.
        lwa_t682i_r-low    = <lfs_t682i>-kotabnr.
        APPEND lwa_t682i_r TO fp_i_t682i_r.
        CLEAR:  lwa_t682i_r, <lfs_t682i>.
      ENDLOOP. " LOOP AT li_t682i ASSIGNING <lfs_t682i>

    ENDIF. " IF sy-subrc IS NOT INITIAL

  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i956(zotc_msg) WITH fp_ctype DISPLAY LIKE c_e. " Condition type & is invalid
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_FETCH_COND_TAB
*&---------------------------------------------------------------------*
*&      Form  F_FIELDS_ACC_COND
*&---------------------------------------------------------------------*
*       Mandatory fields validation
*----------------------------------------------------------------------*
*      -->FP_FCONDTAB  table name
*----------------------------------------------------------------------*
FORM f_fields_acc_cond  USING    fp_fcondtab TYPE tabname. " Table Name

  TYPES:
    BEGIN OF lty_dd03l,
       tabname     TYPE tabname,    " Table Name
       fieldname   TYPE fieldname,  " Field Name
       as4local    TYPE as4local,   " Activation Status of a Repository Object
       as4vers     TYPE as4vers,    " Version of the entry (not used)
       position    TYPE tabfdpos,   " Position of the field in the table
       checktable  TYPE checktable, " Check table name of the foreign key
    END OF lty_dd03l,

    BEGIN OF lty_fch,
       fieldname   TYPE fdname,     " Field name
       checktable  TYPE tabname,    " Table Name
    END OF lty_fch.

  DATA:
      lv_ind        TYPE sytabix,      " Index of Internal Tables
      lv_field       TYPE fieldname,   " Field Name
      lv_count       TYPE i,           " Count of type Integers
      lv_count1      TYPE i,           " Count1 of type Integers
      lv_row_num     TYPE sytabix,     " Index of Internal Tables
      lv_val_counter TYPE i,           " Val_counter of type Integers
      lv_fieldname   TYPE fieldname,   " Field Name
      li_dd03l       TYPE STANDARD TABLE OF lty_dd03l,
      lwa_fch        TYPE lty_fch,
      li_fch         TYPE STANDARD TABLE OF lty_fch,
      lr_data        TYPE REF TO data. "  class

  FIELD-SYMBOLS :
      <lfs_dd03l>     TYPE lty_dd03l,
      <lfs_fch>       TYPE lty_fch,
      <lfs_val>       TYPE any,
      <fs_table>      TYPE STANDARD TABLE,
      <lfs_data_any>  TYPE any,
* ---> Begin of Insert for Defect 959 by DMOIRAN
      <lfs_status>    TYPE zdev_enh_status. " Enhancement Status
* <--- End    of Insert for Defect 959 by DMOIRAN


*---> Begin of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
  DATA :  lwa_row TYPE REF TO cl_abap_structdescr, " Runtime Type Services
         li_component_temp TYPE cl_abap_structdescr=>component_table,
         lwa_component_temp TYPE cl_abap_structdescr=>component.
*<--- End of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.


  SELECT tabname   " Table Name
        fieldname  " Field Name
        as4local   " Activation Status of a Repository Object
        as4vers    " Version of the entry (not used)
        position   " Position of the field in the table
        checktable " Check table name of the foreign key
   FROM dd03l      " Table Fields
   INTO TABLE li_dd03l
   WHERE tabname = fp_fcondtab.
  IF sy-subrc IS INITIAL.

    DESCRIBE TABLE li_dd03l LINES lv_count.
    lv_count1  = lv_count - 2.
* delete last 3 and first 3 records
    DELETE li_dd03l[] FROM ( lv_count1 ) TO ( lv_count ).
    DELETE li_dd03l[] FROM 1 TO 3.
    CLEAR lv_count.

  ENDIF. " IF sy-subrc IS INITIAL

  LOOP AT li_dd03l ASSIGNING <lfs_dd03l>.
    lwa_fch-fieldname  = <lfs_dd03l>-fieldname.
    lwa_fch-checktable = <lfs_dd03l>-checktable.
    APPEND lwa_fch TO li_fch.
    CLEAR: lwa_fch, <lfs_dd03l>.
  ENDLOOP. " LOOP AT li_dd03l ASSIGNING <lfs_dd03l>

  lv_ind = 2.
  READ TABLE i_component ASSIGNING <fs_component> INDEX lv_ind .
  IF sy-subrc IS   INITIAL.
    lv_field = <fs_component>-name.
  ENDIF. " IF sy-subrc IS INITIAL
  TRANSLATE lv_field TO UPPER CASE.

  LOOP AT li_fch ASSIGNING <lfs_fch>.

    IF <lfs_fch>-checktable IS NOT INITIAL.

      CREATE DATA lr_data TYPE  TABLE OF (<lfs_fch>-checktable).
      ASSIGN lr_data->* TO <fs_table>.
      SELECT * FROM (<lfs_fch>-checktable) INTO CORRESPONDING FIELDS OF TABLE <fs_table>.
      IF sy-subrc IS INITIAL.

*---> Begin of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.


*  Get Structure of the table "   Condition table .
        lwa_row ?= cl_abap_typedescr=>describe_by_name( p_name = <lfs_fch>-checktable ).


        IF lwa_row IS NOT INITIAL.
          li_component_temp = lwa_row->get_components( ).
        ENDIF. " IF lwa_row IS NOT INITIAL

        READ TABLE li_component_temp INTO lwa_component_temp WITH KEY name = <lfs_fch>-fieldname.
        IF sy-subrc IS NOT INITIAL.
          UNASSIGN <lfs_status>.
          READ TABLE i_status ASSIGNING <lfs_status>
                                    WITH KEY  criteria = 'CHKTB_XREF'
                                              sel_low  = <lfs_fch>-checktable.
          IF sy-subrc IS NOT INITIAL.
*    error msg, Data not maintained in EMI Table.
            MESSAGE i180(zotc_msg) WITH <lfs_fch>-fieldname  <lfs_fch>-checktable. " Maintain EMI entries for Field & Check table &
            LEAVE LIST-PROCESSING.
          ENDIF. " IF sy-subrc IS NOT INITIAL
        ENDIF. " IF sy-subrc IS NOT INITIAL
*<--- End of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.


        IF <fs_table> IS ASSIGNED.
* to store the name of field
          lv_fieldname = <lfs_fch>-fieldname.

          LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>.
            <lfs_fch>-fieldname = lv_fieldname.

            lv_row_num = sy-tabix.
* To store the value of ZCOUNTER field
* If value is 1, skip validation
            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_dyn_wa> TO <lfs_val>.
            IF <lfs_val> IS ASSIGNED.
              lv_val_counter = <lfs_val>.
            ENDIF. " IF <lfs_val> IS ASSIGNED

            IF lv_val_counter = '1'.
              CONTINUE.
            ELSE. " ELSE -> IF lv_val_counter = '1'

              ASSIGN COMPONENT <lfs_fch>-fieldname OF STRUCTURE <fs_dyn_wa> TO <lfs_data_any>.
              IF sy-subrc IS INITIAL.

                IF <lfs_data_any> IS ASSIGNED.

* ---> Begin of Delete for Defect 959 by DMOIRAN
* Field mapping with EMI table
*                  IF <lfs_fch>-checktable = c_chktabtvak.
*                    <lfs_fch>-fieldname = gv_ref_tvak.
*                  ENDIF. " IF <lfs_fch>-checktable = c_chktabtvak
*
*                  IF <lfs_fch>-checktable = c_chktabtvv5.
*                    <lfs_fch>-fieldname = gv_ref_tvv5.
*                  ENDIF. " IF <lfs_fch>-checktable = c_chktabtvv5
*
*                  IF <lfs_fch>-checktable = c_chktabt005s.
*                    <lfs_fch>-fieldname = gv_ref_t005s.
*                  ENDIF. " IF <lfs_fch>-checktable = c_chktabt005s
*
*                  IF <lfs_fch>-checktable = c_chktabtvm4.
*                    <lfs_fch>-fieldname = gv_ref_tvm4.
*                  ENDIF. " IF <lfs_fch>-checktable = c_chktabtvm4
* <--- End    of Delete for Defect 959 by DMOIRAN
* ---> Begin of Insert for Defect 959 by DMOIRAN
                  READ TABLE i_status ASSIGNING <lfs_status>
                                       WITH KEY  criteria = 'CHKTB_XREF'
                                                 sel_low  = <lfs_fch>-checktable.
                  IF sy-subrc = 0.
                    <lfs_fch>-fieldname = <lfs_status>-sel_high.
                  ENDIF. " IF sy-subrc = 0

* <--- End    of Insert for Defect 959 by DMOIRAN


 " ELSE -> IF <lfs_data_any> IS NOT ASSIGNED
                  READ TABLE <fs_table> WITH KEY (<lfs_fch>-fieldname) = <lfs_data_any>
                   TRANSPORTING NO FIELDS.

                  IF sy-subrc IS NOT  INITIAL.
* Delete records from success record
                    DELETE <fs_dyn_tab_s> INDEX lv_row_num.

                    wa_ereport-msgtyp = c_e.
                    CONCATENATE text-003 <lfs_fch>-fieldname
                    INTO wa_ereport-msgtxt SEPARATED BY space.
                    wa_ereport-value = lv_row_num.
                    APPEND wa_ereport TO i_ereport.
                    CLEAR wa_ereport.
**              MESSAGE i963(zotc_msg) WITH <lfs_fch>-fieldname DISPLAY LIKE c_e. " Invalid field value of field &.
                  ENDIF. " IF sy-subrc IS NOT INITIAL

                ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
 " ELSE -> IF sy-subrc IS NOT INITIAL
                  DELETE TABLE <fs_dyn_tab_s> FROM <fs_dyn_wa>.
                  wa_ereport-msgtyp = c_e.
                  CONCATENATE text-004 <lfs_fch>-fieldname INTO wa_ereport-msgtxt SEPARATED BY space.
                  wa_ereport-value = lv_row_num.
                  APPEND wa_ereport TO i_ereport.
                  CLEAR wa_ereport.

                ENDIF. " IF <lfs_data_any> IS ASSIGNED
              ELSE. " ELSE -> IF sy-subrc = 0
                MESSAGE i962(zotc_msg) WITH <lfs_fch>-fieldname DISPLAY LIKE c_e. " Mandatory field name & is missing from file.
                LEAVE LIST-PROCESSING.
              ENDIF. " IF sy-subrc IS INITIAL
              CLEAR <lfs_data_any>.
            ENDIF. " IF lv_val_counter = '1'
          ENDLOOP. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>

        ENDIF. " IF <fs_table> IS ASSIGNED
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF <lfs_fch>-checktable IS NOT INITIAL
  ENDLOOP. " LOOP AT li_fch ASSIGNING <lfs_fch>

ENDFORM. " F_FIELDS_ACC_COND
*&---------------------------------------------------------------------*
*&      Form  F_WRITETO_APP_SERVER
*&---------------------------------------------------------------------*
*       Write to application server
*----------------------------------------------------------------------*

FORM f_writeto_app_server .
* Local data Declaration
  DATA:
      lv_name_type  TYPE string,
      lv_file_table TYPE string,
      lv_subrc      TYPE sysubrc,         " Return Value of ABAP Statements
      lv_filena     TYPE rlgrap-filename, " Local file for upload/download
      lt_file_table TYPE rsanm_file_table,
      ls_file_table TYPE rsanm_file_line,
      lv_filename   TYPE rlgrap-filename. " Local file for upload/download

* Field Symbol Declaration
  FIELD-SYMBOLS :
    <lfs_ntype>     TYPE ty_ntype,
    <lfs_value>     TYPE any.

* Name of file
  CONCATENATE gv_filenam
              sy-datum
              sy-uzeit
*---> Begin of insert for D2_OTC_EDD_0274/defect 959 by VCHOUDH.
              '_'
              sy-uname
*<--- END of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
         INTO lv_filename
         SEPARATED BY space.

* Get the physical path from logical path
  CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
    EXPORTING
      client                     = sy-mandt
      logical_path               = gv_lpath
      operating_system           = sy-opsys
      file_name                  = lv_filename
    IMPORTING
      file_name_with_path        = lv_filena
    EXCEPTIONS
      path_not_found             = 1
      missing_parameter          = 2
      operating_system_not_found = 3
      file_system_not_found      = 4
      OTHERS                     = 5.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i951(zotc_msg) WITH gv_lpath  DISPLAY LIKE c_e. " No Input file could be retrieved from Logical path &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL
  CLEAR: lv_filename,
          gv_lpath .

  CLEAR ls_file_table.
** Prepare Header data for sending to app server
  LOOP AT i_ntype ASSIGNING <lfs_ntype>.
    CONCATENATE <lfs_ntype>-name <lfs_ntype>-ty INTO lv_name_type SEPARATED BY c_fslash.
    IF sy-tabix = 1.
      ls_file_table = lv_name_type.
    ELSE. " ELSE -> IF sy-tabix = 1
      CONCATENATE ls_file_table lv_name_type INTO ls_file_table SEPARATED BY '||'.
    ENDIF. " IF sy-tabix = 1
  ENDLOOP. " LOOP AT i_ntype ASSIGNING <lfs_ntype>
  CLEAR: lv_name_type.

  APPEND ls_file_table TO lt_file_table.
  CLEAR ls_file_table.

* Prepare data for sending to application server
  IF <fs_dyn_tab_s>  IS NOT INITIAL.

    LOOP AT <fs_dyn_tab_s> ASSIGNING <fs_dyn_wa>.
      WHILE ( lv_subrc EQ 0 ).
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_dyn_wa>  TO <lfs_value>.
        lv_subrc = sy-subrc.
        IF sy-subrc IS INITIAL.

          IF sy-index = 1 .
            ls_file_table = <lfs_value>.
          ELSE. " ELSE -> IF sy-index = 1
            lv_file_table = <lfs_value>.
            CONCATENATE ls_file_table lv_file_table INTO ls_file_table SEPARATED BY '||'.
          ENDIF. " IF sy-index = 1
        ENDIF. " IF sy-subrc IS INITIAL
      ENDWHILE.
      APPEND ls_file_table  TO lt_file_table.
      CLEAR: ls_file_table,
              lv_subrc.
    ENDLOOP. " LOOP AT <fs_dyn_tab_s> ASSIGNING <fs_dyn_wa>
  ENDIF. " IF <fs_dyn_tab_s> IS NOT INITIAL

* File write to app server
  IF lt_file_table IS NOT INITIAL.
* Open Data set for writing File
    TRY .
        OPEN DATASET lv_filena FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      CATCH cx_sy_file_open.
* Leaving the program if OPEN DATASET fails
        MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
        LEAVE LIST-PROCESSING.

      CATCH cx_sy_codepage_converter_init.
        MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
        LEAVE LIST-PROCESSING.

      CATCH cx_sy_conversion_codepage.
        MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
        LEAVE LIST-PROCESSING.

      CATCH cx_sy_file_authority.
        MESSAGE i950(zotc_msg) WITH lv_filena . " No authorization for access to file &
        LEAVE LIST-PROCESSING.

      CATCH  cx_sy_pipes_not_supported.
        MESSAGE i959(zotc_msg) WITH lv_filena . " Error while uploading file to &
        LEAVE LIST-PROCESSING.

      CATCH cx_sy_too_many_files.
        MESSAGE i949(zotc_msg) DISPLAY LIKE c_e. " Maximum number of open files exceeded
        LEAVE LIST-PROCESSING.
    ENDTRY.

    CLEAR ls_file_table.
    LOOP AT lt_file_table INTO ls_file_table .
* Write file to application server
      TRY .
          TRANSFER ls_file_table TO lv_filena.
        CATCH cx_sy_codepage_converter_init .
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_conversion_codepage .
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_file_authority .
          MESSAGE i950(zotc_msg) WITH lv_filena. " No authorization for access to file &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_file_io.
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_file_open .
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_file_open_mode.
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_pipe_reopen .
          MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
          LEAVE LIST-PROCESSING.

        CATCH cx_sy_too_many_files .
          MESSAGE i949(zotc_msg) DISPLAY LIKE c_e. " Maximum number of open files exceeded
          LEAVE LIST-PROCESSING.

      ENDTRY.
    ENDLOOP. " LOOP AT lt_file_table INTO ls_file_table

 "Close Data Set after Writing File
    TRY .
        CLOSE DATASET lv_filena.
      CATCH cx_sy_file_close.
        MESSAGE i959(zotc_msg) WITH lv_filena. " Error while uploading file to &
        LEAVE LIST-PROCESSING.
    ENDTRY.

  ENDIF. " IF lt_file_table IS NOT INITIAL

ENDFORM. " F_WRITETO_APP_SERVER
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY
*&---------------------------------------------------------------------*
*       Display records
*----------------------------------------------------------------------*

FORM f_display_summ_report .

* Local Type Declaration
  TYPES:
     BEGIN OF lty_ereport_f,
        msgtyp TYPE char1,   "Error Type
        msgtxt TYPE char256, "Error Text
        value  TYPE char4,   "Error Key
     END OF lty_ereport_f.

* local variables declaration
  DATA:
        lv_width_msg   TYPE outputlen,           " Output Length
        li_ereport_f   TYPE STANDARD TABLE OF lty_ereport_f,
        lwa_ereport_f  TYPE lty_ereport_f,
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,
        li_fieldcat    TYPE slis_t_fieldcat_alv. "Field Catalog

  FIELD-SYMBOLS: <lfs_ereport> TYPE ty_ereport.

* Count no of total records
  DESCRIBE TABLE <fs_dyn_tab>   LINES gv_tot.
* Count no of success records
  DESCRIBE TABLE <fs_dyn_tab_s> LINES gv_succ.

* Count error records
  gv_err = gv_tot - gv_succ.

  LOOP AT i_ereport ASSIGNING <lfs_ereport>.
    lwa_ereport_f-msgtyp  = <lfs_ereport>-msgtyp.
    lwa_ereport_f-msgtxt  = <lfs_ereport>-msgtxt.
    lwa_ereport_f-value   = <lfs_ereport>-value.

*     Getting the maximum length of columns MSGTXT.
    IF lv_width_msg   LT strlen( <lfs_ereport>-msgtxt ).
      lv_width_msg = strlen( <lfs_ereport>-msgtxt ).
    ENDIF. " IF lv_width_msg LT strlen( <lfs_ereport>-msgtxt )
    APPEND lwa_ereport_f TO li_ereport_f.
    CLEAR lwa_ereport_f.
  ENDLOOP. " LOOP AT i_ereport ASSIGNING <lfs_ereport>

* Message type
  PERFORM f_fill_fieldcat USING 'MSGTYP'
                               'LI_EREPORT_F'
                               'STATUS'
                                 7
                        CHANGING li_fieldcat[].

*   Message Text
  PERFORM f_fill_fieldcat USING 'MSGTXT'
                                'LI_EREPORT_F'
                                'MESSAGE'
                                lv_width_msg
                        CHANGING li_fieldcat[].
*   Message Key
  PERFORM f_fill_fieldcat USING 'VALUE'
                                'LI_EREPORT_F'
                                'ROW NO'
                                6
                        CHANGING li_fieldcat[].

*   Top of page subroutine
  lwa_events-name = 'TOP_OF_PAGE'.
  lwa_events-form = 'F_TOP_OF_PAGE_1'.
  APPEND lwa_events TO li_events.
  CLEAR lwa_events.

*   ALV List Display for Background Run
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = li_fieldcat
      it_events          = li_events
    TABLES
      t_outtab           = li_ereport_f
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE i954(zotc_msg) DISPLAY LIKE c_e. " Error in display summary of file.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE_1
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_top_of_page_1.

* Horizontal Line
  WRITE: / c_hline.
* Total number of records in the given file
  WRITE:/ text-005, gv_tot.
* Number of Success records
  WRITE:/ text-006, gv_succ.
* Number of Error records
  WRITE:/ text-007, gv_err.
* Horizontal Line
  WRITE: / c_hline.

ENDFORM. "f_top_of_page_1
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI_VAL
*&---------------------------------------------------------------------*
*       Subroutine to fetch the EMI values
*----------------------------------------------------------------------*

FORM f_fetch_emi_val .

* Local constant
  CONSTANTS:
      lc_enh_no      TYPE z_enhancement  VALUE 'D2_OTC_EDD_0274', " Enhancement No.
      lc_chktb_xref  TYPE z_criteria     VALUE 'CHKTB_XREF',      " Enh. Criteria
      lc_filepath    TYPE z_criteria     VALUE 'LOGI_PATH',       " Enh. Criteria
      lc_filename    TYPE z_criteria     VALUE 'FILE_NAME'.       " Enh. Criteria

* Local variables declaration
  DATA:
    li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table
* Field Symbol
  FIELD-SYMBOLS:
    <lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CLEAR:gv_ref_tvak,
        gv_ref_tvv5,
        gv_ref_t005s,
        gv_ref_tvm4,
        gv_lpath,
        gv_filenam.

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

* Delete the entries which are not active and pick all the active entries.
  DELETE li_status WHERE active = space.

* ---> Begin of Insert for Defect 959 by DMOIRAN
  i_status[] = li_status[].
* <--- End    of Insert for Defect 959 by DMOIRAN

  READ TABLE li_status ASSIGNING <lfs_status>
                       WITH KEY  criteria = lc_chktb_xref
                                 sel_low  = c_chktabtvak.
  IF sy-subrc IS INITIAL.
    gv_ref_tvak = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc IS INITIAL

  READ TABLE li_status ASSIGNING <lfs_status>
                       WITH KEY  criteria = lc_chktb_xref
                                 sel_low  = c_chktabtvv5.
  IF sy-subrc IS INITIAL.
    gv_ref_tvv5 = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc IS INITIAL

  READ TABLE li_status ASSIGNING <lfs_status>
                     WITH KEY  criteria = lc_chktb_xref
                               sel_low  = c_chktabt005s.
  IF sy-subrc IS INITIAL.
    gv_ref_t005s = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc IS INITIAL

  READ TABLE li_status ASSIGNING <lfs_status>
                     WITH KEY  criteria = lc_chktb_xref
                               sel_low  = c_chktabtvm4.
  IF sy-subrc IS INITIAL.
    gv_ref_tvm4 = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc IS INITIAL

  READ TABLE li_status ASSIGNING <lfs_status>
                     WITH KEY  criteria = lc_filepath.
  IF sy-subrc IS INITIAL.
    gv_lpath = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc IS INITIAL


  READ TABLE li_status ASSIGNING <lfs_status>
                     WITH KEY  criteria = lc_filename.
  IF sy-subrc IS INITIAL.
    gv_filenam = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_FETCH_EMI_VAL
