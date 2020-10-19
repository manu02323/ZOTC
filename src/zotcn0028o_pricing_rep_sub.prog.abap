*&---------------------------------------------------------------------*
*&  Include         ZOTCN0028O_PRICING_REP_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :      ZOTCN0028O_PRICING_REP_SUB                         *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  Include                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0028O_PRICING_REPORT_NEW, it has all the subroutine.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2015 VCHOUDH   E2DK914250 INITIAL DEVELOPMENT -               *
*&---------------------------------------------------------------------*
* 27-Aug-2015 SAGARWA1  E2DK914250 Defeect #913
*&---------------------------------------------------------------------*
*01-Dec-2015  VCHOUDH  E2DK916259  Defect 1264 - Short Dump for        *
*                                  multiple customers in selection     *
*                                 Check if the pricing condition type  *
*                                 is of discount type T685A-KNEGA = 'X'*
*                               If so,then remove the -ve sign in kbetr.
*&---------------------------------------------------------------------*
*03-May-2016  SAGARWA1  E2DK917740 Defect 1519 - Multiple Changes      *
*                                  Req 1:Check for authorization object*
*                                  V_KONH_VKO & V_KONH_VKS.            *
*                                  Req 2:System should pick the record *
*                                  for territory based on the effective*
*                                  date of territory assignment.       *
*                                  Req 3:System should ignore territory*
*                                  assignment table entries if there is*
*                                  no value maintained and user should *
*                                  be able to fetch the record with    *
*                                  blank Territory field in the report.*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*15-Nov-2016  APODDAR  E2DK919729  Defect 2158 - Change in Logic Use of*
*                                  Custom Authorization Object ZOTC0028*
*&---------------------------------------------------------------------*
*10-Apr-2017  DMOIRAN  E1DK926899  D3 COE Defect 2479.
* 1. Added Quantity scale pricing condition type eg, ZB00
* 2. Fixed the download issue when Sales Rep is not there.
* 3. Fixed the scale UoM issue.
* 4. For currency having no decimal eg, KRW, the amount should be
*    displayed like that in VK13 (without decimal points).
*&---------------------------------------------------------------------*
* 30-June-2017 MGARG  E1DK928877  Defect#3034:  Sales rep Filteration  *
*                                 logic updated                        *
*&---------------------------------------------------------------------*
* 04-Sep-2018 U033876 E2DK920249  SCTASK0728808 Defect#6955:EHP8 Upgrad*
*                                 issue p_tab declared wrt kotabnr and *
*                                 in ehp8 kotabnr is Char3 value so    *
*                                 short dump, in earlier ver it is NUMC3*
***********************************************************************
* 02-Jan-2019 SMUKHER E1DK939981  Defect#7919:  Performance improvement*
*                                 needed as short dump was coming due  *
*                                 to memory overflow in internal tables*
************************************************************************
*28-June-2019 U105993 E2DK923801 Defect#9379: Performance improvement  *
*                                Added Not Initial check               *
************************************************************************
*28-Oct-2019 RNATHAK E2DK927757 INC0524176-01 : Performance Issue fix
************************************************************************
*&---------------------------------------------------------------------*
* 27-Dec-2019 U106341                HANAtization Changes              *
*----------------------------------------------------------------------*


************************************************************************
*   F4 help for condition table .
************************************************************************
FORM f_get_condition_tab .


  TYPES : BEGIN OF lty_t685,
            kvewe TYPE t685-kvewe, " Usage of the condition table
            kappl TYPE t685-kappl, " Application
            kschl TYPE t685-kschl, " Condition Type
            kozgf TYPE t685-kozgf, " Access sequence
          END OF lty_t685.

  TYPES : BEGIN OF lty_t682i,
            kvewe   TYPE   t682i-kvewe,   " Usage of the condition table
            kappl   TYPE   t682i-kappl,   " Application
            kozgf   TYPE   t682i-kozgf,   " Access sequence
            kolnr   TYPE   t682i-kolnr,   " Access sequence - Access number
            kotabnr TYPE   t682i-kotabnr, " Condition table
          END OF lty_t682i.

  TYPES : BEGIN OF lty_temp,
            kotabnr TYPE   t682i-kotabnr, " Access sequence
            gstru   TYPE   tmc1t-gstru,   " Generated DDIC table for LIS, conditions, messages
            gstxt   TYPE   tmc1t-gstxt,   " Explanatory short text
          END OF lty_temp.
  TYPES : BEGIN OF lty_tmc1t,
            spras TYPE  tmc1t-spras, " Language Key
            gstru TYPE  tmc1t-gstru, " Generated DDIC table for LIS, conditions, messages
            gstxt TYPE tmc1t-gstxt, " Explanatory short text
          END OF lty_tmc1t.


  DATA : lwa_t685  TYPE lty_t685,
         li_t682i  TYPE TABLE OF lty_t682i,
         lwa_t682i TYPE lty_t682i,
         li_temp   TYPE TABLE OF lty_temp,
         lwa_temp  TYPE lty_temp,
         li_tmc1t  TYPE TABLE OF lty_tmc1t. " Short Texts on Generated DDIC Structures


  FIELD-SYMBOLS : <lfs_tmc1t> TYPE lty_tmc1t,
                  <lfs_temp>  TYPE lty_temp.
  CONSTANTS : lc_s     TYPE char1 VALUE 'S'. "Value Org
  DATA : li_retval  TYPE STANDARD TABLE OF ddshretval, "Return records
         lwa_return TYPE ddshretval.                   "Return records
  DATA :li_dynpread  TYPE TABLE OF dynpread, " Fields of the current screen (with values)
        lwa_dynpread TYPE dynpread.         " Fields of the current screen (with values)

  CONSTANTS : lc_kschl   TYPE dynfnam VALUE 'P_KSCHL',            " Field name
              lc_kappl   TYPE dynfnam VALUE 'P_KAPPL',            " Field name
              lc_kotabnr TYPE dfies-fieldname VALUE 'KOTABNR', " Field Name
              lc_kvewe   TYPE kvewe VALUE 'A'.                    " Usage of the condition table

  REFRESH li_temp.


  lwa_dynpread-fieldname = lc_kschl.
  APPEND lwa_dynpread TO li_dynpread.
  CLEAR lwa_dynpread.
  lwa_dynpread-fieldname = lc_kappl.
  APPEND lwa_dynpread TO li_dynpread.


*  fetching the values of the field in runtime .
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = li_dynpread.
  LOOP AT li_dynpread INTO lwa_dynpread.
    IF lwa_dynpread-fieldname = lc_kschl.
      p_kschl = lwa_dynpread-fieldvalue.
      TRANSLATE p_kschl TO UPPER CASE.
    ENDIF. " IF lwa_dynpread-fieldname = lc_kschl
    IF lwa_dynpread-fieldname = lc_kappl.

      p_kappl = lwa_dynpread-fieldvalue.
      TRANSLATE p_kappl TO UPPER CASE.
    ENDIF. " IF lwa_dynpread-fieldname = lc_kappl
  ENDLOOP. " LOOP AT li_dynpread INTO lwa_dynpread


  IF p_kappl IS NOT INITIAL AND p_kschl IS NOT INITIAL.

* Fetching the access sequence.
    SELECT SINGLE
           kvewe " Usage of the condition table
           kappl " Application
           kschl " Condition Type
           kozgf " Access sequence
      FROM t685  " Conditions: Types
      INTO lwa_t685
      WHERE kvewe = lc_kvewe
      AND   kappl = p_kappl
      AND   kschl = p_kschl.
    IF sy-subrc IS INITIAL.
*      Fetching the condition table .
      SELECT kvewe   " Usage of the condition table
             kappl   " Application
             kozgf   " Access sequence
             kolnr   " Access sequence - Access number
             kotabnr " Condition table
      FROM t682i     " Conditions: Access Sequences (Generated Form)
      INTO TABLE li_t682i
      WHERE kvewe = lwa_t685-kvewe
        AND kappl = lwa_t685-kappl
        AND kozgf = lwa_t685-kozgf.
      IF sy-subrc IS INITIAL.

        LOOP AT li_t682i INTO lwa_t682i.
          CLEAR : lwa_temp.
          CONCATENATE lwa_t682i-kvewe lwa_t682i-kotabnr INTO lwa_temp-gstru.
          lwa_temp-kotabnr = lwa_t682i-kotabnr.
          APPEND lwa_temp TO li_temp.
        ENDLOOP. " LOOP AT li_t682i INTO lwa_t682i


*** To get the description of the condition tables.


        IF li_temp IS NOT INITIAL.
*          Fetching the description of the condition table .
          SELECT spras " Language Key
                 gstru " Generated DDIC table for LIS, conditions, messages
                 gstxt " Explanatory short text
            FROM tmc1t " Short Texts on Generated DDIC Structures
            INTO TABLE li_tmc1t
            FOR ALL ENTRIES IN li_temp
            WHERE spras = sy-langu
            AND gstru = li_temp-gstru.
          IF sy-subrc IS INITIAL.
            SORT li_tmc1t BY gstru .
            LOOP AT li_temp ASSIGNING <lfs_temp>.
              READ TABLE li_tmc1t ASSIGNING <lfs_tmc1t> WITH KEY gstru = <lfs_temp>-gstru BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                <lfs_temp>-gstxt = <lfs_tmc1t>-gstxt.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDLOOP. " LOOP AT li_temp ASSIGNING <lfs_temp>

          ENDIF. " IF sy-subrc IS INITIAL



*  Checking the table, if data exists then display the F4 help.

          CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
            EXPORTING
              retfield        = lc_kotabnr
              dynpprog        = sy-repid
              value_org       = lc_s
            TABLES
              value_tab       = li_temp
              return_tab      = li_retval
            EXCEPTIONS
              parameter_error = 1
              no_values_found = 2
              OTHERS          = 3.
          IF sy-subrc IS INITIAL.
            READ TABLE li_retval INTO lwa_return INDEX 1 .
            IF sy-subrc IS INITIAL.
              p_tab =  lwa_return-fieldval. "   copy the data to the selection field.

              READ TABLE li_temp ASSIGNING <lfs_temp> WITH KEY kotabnr = p_tab BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                gv_table = <lfs_temp>-gstru.
              ENDIF. " IF sy-subrc IS INITIAL
              CLEAR lwa_return.
              REFRESH: li_retval.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc IS INITIAL

        ENDIF. " IF li_temp IS NOT INITIAL

      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF p_kappl IS NOT INITIAL AND p_kschl IS NOT INITIAL
    MESSAGE i068 DISPLAY LIKE TEXT-052.
  ENDIF. " IF p_kappl IS NOT INITIAL AND p_kschl IS NOT INITIAL
*'F4IF_INT_TABLE_VALUE_REQUEST'

ENDFORM. " GET_CONDITION_TAB
*&---------------------------------------------------------------------*
*&      Form  GET_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_details .
  DATA : lv_string TYPE gstru. " String of type CHAR4

  IF p_rdat IS INITIAL.
    CLEAR p_datab.
  ENDIF. " IF p_rdat IS INITIAL

  IF p_rdatbi IS INITIAL.
    CLEAR s_datbi[].
  ENDIF. " IF p_rdatbi IS INITIAL

*  IF gv_table IS INITIAL.
  CLEAR : gv_table.
  CONCATENATE 'A' p_tab INTO lv_string.
  gv_table = lv_string.
*  ENDIF. " IF gv_table IS INITIAL

  IF gv_table IS INITIAL.
    MESSAGE e067 DISPLAY LIKE TEXT-052. " Condition Table not entered
  ENDIF. " IF gv_table IS INITIAL


*Short Texts on Generated DDIC Structures
  SELECT SINGLE spras " Language Key
                gstru " Generated DDIC table for LIS, conditions, messages
                gstxt " Explanatory short text
     FROM tmc1t INTO wa_tmc1t
    WHERE spras = sy-langu
         AND gstru = lv_string.


ENDFORM. " GET_DETAILS
*&---------------------------------------------------------------------*
*&      Form  CREATE_STRUCTURES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_structures .

  DATA: lo_typedescr  TYPE REF TO cl_abap_typedescr. " Runtime Type Services

*  DATA : lv_table TYPE string,
*         lv_field TYPE string,
*         lv_delement  TYPE string .
  DATA : lv_flag1 TYPE char1. " Flag1 of type CHAR1

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

  CONSTANTS : lc_kunn2 TYPE char5   VALUE 'KUNN2',         " Kunn2 of type CHAR5
              lc_terri TYPE char13  VALUE 'ZTERRITORY_ID'. " Terri of type CHAR13

*& <-- End  of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

****  Get data from EMI.
*** Data is stored to get the fields for which description is needed.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enhancement_no
    TABLES
      tt_enh_status     = i_enh_status.


** Get Structure of the table "   Condition table .
  wa_row ?= cl_abap_typedescr=>describe_by_name( p_name = gv_table ).

*  *** Get the components in the extracted structrue
** And add one more field for Pricing condition value
  IF wa_row IS NOT INITIAL.
    i_component = wa_row->get_components( ).
    CLEAR wa_component.
    MOVE c_kbetr TO wa_component-name.
    wa_component-type ?= cl_abap_datadescr=>describe_by_name( c_kbetr_de ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kbetr_de ).
    APPEND wa_component TO i_component.

  ENDIF. " IF wa_row IS NOT INITIAL


** Moving fields according to the requirement.

** Begin of Change for Defect#913 by SAGARWA1
** Add the ZTABLE column at the first poistion
  CLEAR wa_component_temp.
  MOVE c_table TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_ztable ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_ztable ).
  APPEND wa_component_temp TO i_component_temp.

  wa_fdtl-fieldname = c_table.
  wa_fdtl-rollname = c_ztable.
  APPEND wa_fdtl TO i_fdtl.

** End of Change for Defect#913 by SAGARWA1

***********   Counter .
  CLEAR wa_component_temp.
  MOVE c_counter TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_counter ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_counter ).
  APPEND wa_component_temp TO i_component_temp.

  wa_fdtl-fieldname = c_counter.
  wa_fdtl-rollname = c_counter.
  APPEND wa_fdtl TO i_fdtl.


  wa_fdtl-fieldname = c_kbetr.
  wa_fdtl-rollname = c_kbetr_de.
  APPEND wa_fdtl TO i_fdtl.

** Begin of Change for Defect#913 by SAGARWA1
  wa_fdtl-fieldname = c_kbetr1.
  wa_fdtl-rollname = c_kbetr_de.
  APPEND wa_fdtl TO i_fdtl.
**  End   of Change for Defect#913 by SAGARWA1

***** Condition Type
  CLEAR wa_component_temp.
  MOVE c_kschl TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kschl ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kschl ).
  APPEND wa_component_temp TO i_component_temp.


*****  Condition Table
  CLEAR wa_component_temp.
  MOVE c_kotabnr TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kotabnr ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kotabnr ).
  APPEND wa_component_temp TO i_component_temp.

  wa_fdtl-fieldname = c_kotabnr.
  wa_fdtl-rollname = c_kotabnr.
  APPEND wa_fdtl TO i_fdtl.


  LOOP AT i_component INTO wa_component.
    IF wa_component-name = c_kschl.
      CONTINUE.
    ENDIF. " IF wa_component-name = c_kschl
    CLEAR wa_component_temp.
    wa_component_temp = wa_component.
    APPEND wa_component_temp TO i_component_temp.

****   Appending the description.
    CASE wa_component-name.
      WHEN 'VKORG'.
        CLEAR wa_component_temp.
        wa_component_temp-name = 'VKORG_DESC'.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'VTWEG'. "   table TVTWT
        CLEAR wa_component_temp.
        wa_component_temp-name = 'VTWEG_DESC'.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'MATNR'.
        CLEAR wa_component_temp.
        MOVE 'MATNR_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'MAKTX' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'MAKTX' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'KUNNR'.
        CLEAR wa_component_temp.
        MOVE 'KUNNR_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'KUNAG'.
        CLEAR wa_component_temp.
        MOVE 'KUNAG_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'KUNWE'.
        CLEAR wa_component_temp.
        MOVE 'KUNWE_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.

      WHEN 'KDGRP'.
        CLEAR wa_component_temp.
        MOVE 'KDGRP_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKATR7'.
        CLEAR wa_component_temp.
        MOVE 'ZZKATR7_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'BRSCH'.
        CLEAR wa_component_temp.
        MOVE 'BRSCH_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'TEXT1_016T' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'TEXT1_016T' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZMVGR4'.
        CLEAR wa_component_temp.
        MOVE 'ZZMVGR4_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI40' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI40' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'KONDM'.
        CLEAR wa_component_temp.
        MOVE 'KONDM_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKDKG1'.
        CLEAR wa_component_temp.
        MOVE 'ZZKDKG1_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKDKG2'.
        CLEAR wa_component_temp.
        MOVE 'ZZKDKG2_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.

      WHEN 'ZZKDKG3'.
        CLEAR wa_component_temp.
        MOVE 'ZZKDKG3' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTEXT' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'UPMAT'.
        CLEAR wa_component_temp.
***************************      MOVE lv_field TO wa_component_temp-name.
***************************      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( lv_delement ) . "( 'KOTABNR' ).
***************************      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( lv_delement ) . "( 'KOTABNR' ).
***************************      APPEND wa_component_temp TO i_component_temp.
      WHEN 'MFRGR'.
        CLEAR wa_component_temp.
        MOVE 'MFRGR_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKUKLA'.
        CLEAR wa_component_temp.
        MOVE 'ZZKUKLA_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        APPEND wa_component_temp TO i_component_temp.

      WHEN 'ZZKVGR1'.
        CLEAR wa_component_temp.
        MOVE 'ZZKVGR1_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKVGR2'.
        CLEAR wa_component_temp.
        MOVE 'ZZKVGR2_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZKVGR5'.
        CLEAR wa_component_temp.
        MOVE 'ZZKVGR5_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
        APPEND wa_component_temp TO i_component_temp.

      WHEN 'WERKS'.
        CLEAR wa_component_temp.
        MOVE 'WERKS_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'NAME1' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'NAME1' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'AUART'.
        CLEAR wa_component_temp.
        MOVE 'AUART_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'AUGRU'.
        CLEAR wa_component_temp.
        MOVE 'AUGRU_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI40' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI40' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'ZZBSARK'.
        CLEAR wa_component_temp.
        MOVE 'ZZBSARK_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'PSTYV'.

      WHEN 'INCO1'.
        CLEAR wa_component_temp.
        MOVE 'INCO1_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI30' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI30' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.
      WHEN 'TRAGR'.
        CLEAR wa_component_temp.
        MOVE 'TRAGR_DESC' TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) . "( 'KOTABNR' ).
        APPEND wa_component_temp TO i_component_temp.

    ENDCASE.




** for Sales Rep.
* Begin of Change for Defect#913 by SAGARWA1
** If the customer is already added to the componenet table then no need to add again
* No need for Binary serach as the table will contain less than 100 entries.
    READ TABLE i_component_temp TRANSPORTING NO FIELDS WITH KEY name = c_kunnr.
    IF sy-subrc NE 0.
* End   of Change for Defect#913 by SAGARWA1
      IF wa_component-name = c_kunnr. " Customer .
        CLEAR wa_component_temp.
        MOVE c_kunnr TO wa_component_temp-name.
        wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kunn2 ) .
        lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kunn2 ) .
        APPEND wa_component_temp TO i_component_temp.
      ENDIF. " IF wa_component-name = c_kunnr
* Begin of Change for Defect#913 by SAGARWA1
    ENDIF. " IF sy-subrc NE 0
* End   of Change for Defect#913 by SAGARWA1
  ENDLOOP. " LOOP AT i_component INTO wa_component

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
*** Territory ID should be present even if sales rep is not maintained for customer/material
  CLEAR wa_component_temp.
  MOVE lc_kunn2 TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( lc_terri ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( lc_terri ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.

*& <-- End  of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

  IF gv_srep_flag = 'X'.
*& --> Begin of Delete for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
** This code is deleted as Territory field is needed inspite of Sales rep condition
****    CLEAR wa_component_temp.
****    MOVE 'KUNN2' TO wa_component_temp-name.
****    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'ZTERRITORY_ID' ) . "( 'KOTABNR' ).
****    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'ZTERRITORY_ID' ) . "( 'KOTABNR' ).
****    APPEND wa_component_temp TO i_component_temp.
*& <-- End  of Delete for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

    CLEAR wa_component_temp.
    MOVE 'KUNN2_DESC' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'NAME1_GP' ) . "( 'KOTABNR' ).
    APPEND wa_component_temp TO i_component_temp.


    CLEAR wa_component_temp.
    MOVE 'LAND1' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'LAND1_GP' ) . "( 'KOTABNR' ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'LAND1_GP' ) . "( 'KOTABNR' ).
    APPEND wa_component_temp TO i_component_temp.


    CLEAR wa_component_temp.
    MOVE 'ORT01' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'ORT01_GP' ) . "( 'KOTABNR' ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'ORT01_GP' ) . "( 'KOTABNR' ).
    APPEND wa_component_temp TO i_component_temp.


*          CLEAR wa_component_temp.
*          MOVE 'LANDX' TO wa_component_temp-name.
*          wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'LANDX' ) . "( 'KOTABNR' ).
*          lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'LANDX' ) . "( 'KOTABNR' ).
*          APPEND wa_component_temp TO i_component_temp.

    CLEAR wa_component_temp.
    MOVE 'PSTLZ' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'PSTLZ' ) . "( 'KOTABNR' ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'PSTLZ' ) . "( 'KOTABNR' ).
    APPEND wa_component_temp TO i_component_temp.

    CLEAR wa_component_temp.
    MOVE 'REGIO' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'REGIO' ) . "( 'KOTABNR' ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'REGIO' ) . "( 'KOTABNR' ).
    APPEND wa_component_temp TO i_component_temp.

    CLEAR wa_component_temp.
    MOVE 'REGIO_DESC' TO wa_component_temp-name.
    wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
    APPEND wa_component_temp TO i_component_temp.

* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
* Added the field name and data element to be used for Sales Rep
* fields.
    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'KUNN2_DESC'.
    wa_fdtl-rollname = 'NAME1_GP'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'LAND1'.
    wa_fdtl-rollname = 'LAND1_GP'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'ORT01'.
    wa_fdtl-rollname = 'ORT01_GP'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'LANDX'.
    wa_fdtl-rollname = 'LANDX'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'PSTLZ'.
    wa_fdtl-rollname = 'PSTLZ'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'REGIO'.
    wa_fdtl-rollname = 'REGIO'.
    APPEND wa_fdtl TO i_fdtl.

    CLEAR wa_fdtl.
    wa_fdtl-fieldname = 'REGIO_DESC'.
    wa_fdtl-rollname = 'BEZEI20'.
    APPEND wa_fdtl TO i_fdtl.


* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN
  ENDIF. " IF gv_srep_flag = 'X'


*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.

  CLEAR: wa_component, lv_flag1.
  READ TABLE i_component INTO wa_component WITH KEY name = 'KUNAG'.
  IF sy-subrc IS INITIAL.
    lv_flag1 = abap_true.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    READ TABLE i_component INTO wa_component WITH KEY name = 'KUNWE'.
    IF sy-subrc IS INITIAL.
      lv_flag1 = abap_true.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      READ TABLE i_component INTO wa_component WITH KEY name = 'KUNNR'.
      IF sy-subrc IS INITIAL.
        lv_flag1 = abap_true.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
  IF lv_flag1 = abap_true.
    CLEAR wa_component_temp.
    READ TABLE i_component_temp INTO wa_component_temp WITH KEY name = 'ZZKVGR1'.
    IF sy-subrc IS NOT INITIAL.
      CLEAR wa_component_temp.
      MOVE c_zzkvgr1 TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'KVGR1' ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'KVGR1' ) .
      APPEND wa_component_temp TO i_component_temp.

      wa_fdtl-tabname = 'KNVV'.
      wa_fdtl-fieldname = c_zzkvgr1.
      wa_fdtl-rollname = 'KVGR1'.
      APPEND wa_fdtl TO i_fdtl.


      CLEAR wa_component_temp.
      MOVE 'ZZKVGR1_DESC' TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
      APPEND wa_component_temp TO i_component_temp.

    ENDIF. " IF sy-subrc IS NOT INITIAL

    CLEAR wa_component_temp.
    READ TABLE i_component_temp INTO wa_component_temp WITH KEY name = 'ZZKVGR2'.
    IF sy-subrc IS NOT INITIAL.
      CLEAR wa_component_temp.
      MOVE c_zzkvgr2 TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'KVGR2' ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'KVGR2' ) .
      APPEND wa_component_temp TO i_component_temp.

      wa_fdtl-tabname = 'KNVV'.
      wa_fdtl-fieldname = c_zzkvgr2.
      wa_fdtl-rollname = 'KVGR2'.
      APPEND wa_fdtl TO i_fdtl.


      CLEAR wa_component_temp.
      MOVE 'ZZKVGR2_DESC' TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'BEZEI20' ) .
      APPEND wa_component_temp TO i_component_temp.
    ENDIF. " IF sy-subrc IS NOT INITIAL

    CLEAR wa_component_temp.
    READ TABLE i_component_temp INTO wa_component_temp WITH KEY name = 'KDGRP'.
    IF sy-subrc IS NOT INITIAL.

      CLEAR wa_component_temp.
      MOVE c_kdgrp TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kdgrp ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kdgrp ) .
      APPEND wa_component_temp TO i_component_temp.


      wa_fdtl-tabname = 'KNVV'.
      wa_fdtl-fieldname = c_kdgrp.
      wa_fdtl-rollname = c_kdgrp.
      APPEND wa_fdtl TO i_fdtl.


      CLEAR wa_component_temp.
      MOVE 'KDGRP_DESC' TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( 'VTXTK' ) . "( 'KOTABNR' ).
      APPEND wa_component_temp TO i_component_temp.
    ENDIF. " IF sy-subrc IS NOT INITIAL



    CLEAR wa_component_temp.
    READ TABLE i_component_temp INTO wa_component_temp WITH KEY name = 'KUKLA'.
    IF sy-subrc IS NOT INITIAL.

      CLEAR wa_component_temp.
      MOVE c_kukla TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kukla ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kukla ) .
      APPEND wa_component_temp TO i_component_temp.

      wa_fdtl-tabname = 'KNVV'.
      wa_fdtl-fieldname = c_kukla.
      wa_fdtl-rollname = c_kukla.
      APPEND wa_fdtl TO i_fdtl.


      CLEAR wa_component_temp.
      MOVE c_kukla_desc TO wa_component_temp-name.
      wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kukla_desc_d ) .
      lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kukla_desc_d ) .
      APPEND wa_component_temp TO i_component_temp.

    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF lv_flag1 = abap_true
*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.





** Begin of Change for Defect#913 by SAGARWA1
* Add Currency Column
  CLEAR wa_component_temp.
  MOVE c_konwa TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_konwa ) .
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_konwa ) .
  APPEND wa_component_temp TO i_component_temp.
** End   of Change for Defect#913 by SAGARWA1

*** Adding fields from KONP Table.
**** in the strusture.
  CLEAR wa_component_temp.
  MOVE c_kstbm TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kstbm ) .
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kstbm ) .
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_konms TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_konms ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_konms ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_kbetr1 TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kbetr_de ) .
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kbetr_de ) .
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_konws TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_konws ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_konws ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_kpein TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kpein ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kpein ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_kmein TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_kmein ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_kmein ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.

  CLEAR wa_component_temp.
  MOVE c_loevm_ko TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_loevm_ko ) . "( 'KOTABNR' ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_loevm_ko ) . "( 'KOTABNR' ).
  APPEND wa_component_temp TO i_component_temp.



*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191.
  CLEAR wa_component_temp.
  MOVE c_record TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_zrecord ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_zrecord ).
  APPEND wa_component_temp TO i_component_temp.

  wa_fdtl-fieldname = c_record.
  wa_fdtl-rollname = c_zrecord.
  APPEND wa_fdtl TO i_fdtl.



  CLEAR wa_component_temp.
  MOVE c_record_txt TO wa_component_temp-name.
  wa_component_temp-type ?= cl_abap_datadescr=>describe_by_name( c_zrecord_txt ).
  lo_typedescr ?= cl_abap_datadescr=>describe_by_name( c_zrecord_txt ).
  APPEND wa_component_temp TO i_component_temp.


  wa_fdtl-fieldname = c_record_txt.
  wa_fdtl-rollname = c_zrecord_txt.
  APPEND wa_fdtl TO i_fdtl.


*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191.



  REFRESH : i_component.
  i_component = i_component_temp.
  DESCRIBE TABLE i_component LINES gv_val_index.

** Create new line type with added field
  CLEAR : wa_frow.
  TRY.
      wa_frow = cl_abap_structdescr=>create( p_components = i_component ).
    CATCH cx_sy_struct_creation .
  ENDTRY.


** Create the Internal Table structure
  IF wa_frow IS NOT INITIAL.
    CLEAR : i_tab.
    TRY.
        i_tab = cl_abap_tabledescr=>create( p_line_type  = wa_frow ).
      CATCH cx_sy_table_creation .
    ENDTRY.
  ENDIF. " IF wa_frow IS NOT INITIAL

  IF i_tab IS NOT INITIAL.
    CREATE DATA gt_tab TYPE HANDLE i_tab. " Internal ID of an object
    CREATE DATA gt_tab_temp TYPE HANDLE i_tab. " Internal ID of an object
    CREATE DATA gt_tab_temp1 TYPE HANDLE i_tab. " Internal ID of an object

*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
    CREATE DATA gt_tab_temp_srep TYPE HANDLE i_tab. " Internal ID of an object
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG

  ENDIF. " IF i_tab IS NOT INITIAL
  ASSIGN gt_tab->* TO <gfs_tab>.
  ASSIGN gt_tab_temp->* TO <gfs_tab_temp>.

*--> Begin of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
  ASSIGN gt_tab_temp1->* TO <gfs_tab_temp1>.
*<-- End of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.

*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
  ASSIGN gt_tab_temp_srep->* TO <gfs_tab_temp_srep>.
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG

  IF wa_row IS NOT INITIAL.
*    CREATE DATA gs_row TYPE HANDLE wa_row. " Internal ID of an object
    CREATE DATA gs_row LIKE LINE OF <gfs_tab>.
    CREATE DATA gs_row_temp LIKE LINE OF <gfs_tab>.
  ENDIF. " IF wa_row IS NOT INITIAL

  ASSIGN gs_row->* TO <gfs_row>.
  ASSIGN gs_row_temp->* TO <gfs_row_temp>.
ENDFORM. " CREATE_STRUCTURES
*&---------------------------------------------------------------------*
*&      Form  FREE_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_selection .

  REFRESH : i_tables, i_fields, i_fields_n.
  CLEAR   : wa_tables, wa_fields.
  CLEAR   : gv_sid.
  CLEAR   : wa_dyns, gv_num.
  REFRESH : i_where, i_where_add.


  REFRESH : i_field_list.
  CLEAR : wa_field_list.

** Extract Primary Key fields
  CALL METHOD cl_reca_ddic_tabl=>get_field_list
    EXPORTING
      id_name            = gv_table
      if_suppress_mandt  = abap_true
      if_suppress_key    = abap_false
      if_suppress_nonkey = abap_true
    IMPORTING
      et_field_list      = i_field_list
    EXCEPTIONS
      not_found          = 1
      OTHERS             = 2.


*** Creating the Dynamic where clause.
  IF i_field_list IS NOT INITIAL.
** Delete the Mandatory fields available in Selection screen so that
** these fields will not show in Free Selection
    DELETE i_field_list WHERE fieldname EQ c_kappl.
    IF sy-subrc EQ 0.
      CLEAR : wa_where.
      CONCATENATE '''' p_kappl '''' INTO gv_kappl.
      CONCATENATE '(' 'KAPPL EQ ' gv_kappl ')' INTO wa_where-line SEPARATED BY space.
      APPEND wa_where TO i_where.
    ENDIF. " IF sy-subrc EQ 0
    DELETE i_field_list WHERE fieldname EQ c_kschl.
    IF sy-subrc EQ 0.
      IF i_where[] IS NOT INITIAL.
        CLEAR : wa_where.
        MOVE 'AND' TO wa_where-line.
        APPEND wa_where TO i_where.
      ENDIF. " IF i_where[] IS NOT INITIAL
      CONCATENATE '''' p_kschl '''' INTO gv_kschl.
      CONCATENATE '(' 'KSCHL EQ' gv_kschl ')' INTO wa_where-line SEPARATED BY space.
      APPEND wa_where TO i_where.
    ENDIF. " IF sy-subrc EQ 0

*  Begin of Change for Defect#913 by SAGARWA1
    DELETE i_field_list WHERE fieldname EQ c_datbi.
*  End   of Change for Defect#913 by SAGARWA1

    MOVE 'F' TO gv_kind. "Activate only Key fields in Free Selection.
    LOOP AT i_field_list INTO wa_field_list.
      CLEAR : wa_fields.
      MOVE gv_table TO wa_fields-tablename.
      MOVE wa_field_list-fieldname TO wa_fields-fieldname.
      APPEND wa_fields TO i_fields.
    ENDLOOP. " LOOP AT i_field_list INTO wa_field_list
  ELSE. " ELSE -> IF i_field_list IS NOT INITIAL
    MOVE 'T' TO gv_kind. "Activate all fields in Free- Selections
  ENDIF. " IF i_field_list IS NOT INITIAL

  MOVE gv_table TO wa_tables-prim_tab.
  APPEND wa_tables TO i_tables.

****  Free selection screen is created .
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = gv_kind
      expressions              = wa_dyns-texpr
    IMPORTING
      selection_id             = gv_sid
      where_clauses            = wa_dyns-clauses
      expressions              = wa_dyns-texpr
      field_ranges             = wa_dyns-trange
      number_of_active_fields  = gv_num
    TABLES
      tables_tab               = i_tables
      fields_tab               = i_fields
      fields_not_selected      = i_fields_n
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.
  IF sy-subrc EQ 0.
*    ** Call Free Selection Dialog Screen **
    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id            = gv_sid
        title                   = TEXT-055
        as_window               = ' '
        alv                     = ' '
        tree_visible            = TEXT-057
      IMPORTING
        where_clauses           = wa_dyns-clauses
        expressions             = wa_dyns-texpr
        field_ranges            = wa_dyns-trange
        number_of_active_fields = gv_num
      TABLES
        fields_tab              = i_fields
        fields_not_selected     = i_fields_n
      EXCEPTIONS
        internal_error          = 1
        no_action               = 2
        selid_not_found         = 3
        illegal_status          = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
      MESSAGE e069 DISPLAY LIKE TEXT-051. " Invalid Selection
*      LEAVE TO SCREEN 1000.
      LEAVE LIST-PROCESSING .
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-subrc EQ 0
ENDFORM. " FREE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fetch_data .
  TYPES : BEGIN OF lty_konh ,
            knumh TYPE knumh, " Condition record number
          END OF lty_konh.

** Begin of Change for Defect#913 by SAGARWA1
  TYPES : BEGIN OF lty_territ_assn ,
            vkorg          TYPE   vkorg,           " Sales Organization
            vtweg          TYPE   vtweg,           " Distribution Channel
            spart          TYPE   spart,           " Division
            kunnr          TYPE   kunnr,           " Customer Number
            territory_id   TYPE  zterritory_id, " Partner Territory ID
            partrole       TYPE zpart_role,        " Partner Role
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
            effective_from TYPE zeffect_date, " Effective From
            effective_to   TYPE zexpiry_date, " Effective To
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
          END OF lty_territ_assn.

*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
  TYPES : BEGIN OF lty_t685a,
            kappl TYPE  kappl,    " Application
            kschl TYPE  kscha,    " Condition type
            kzbzg TYPE  kzbzg,    " Scale basis indicator "++COE D3 Defect 2479
            knega TYPE  knega,    " Plus/minus sign of the condition amount "++"COE D3 Defect 2479
            txtgr TYPE  txtgr,    " Text determination procedure
            tdid  TYPE  tdid_tec, " Text ID for text edit control
          END OF lty_t685a.
  DATA : lwa_t685a TYPE lty_t685a.
  DATA : lv_name TYPE tdobname, " Name
         lv_obj  TYPE tdobject.  " Texts: Application Object
*               lv_id TYPE tdid .
  CONSTANTS : lc_konp    TYPE char4 VALUE 'KONP', " Konp of type CHAR4
              lc_value_b TYPE kzbzg VALUE 'B',    " Scale basis indicator
              lc_qty_c   TYPE kzbzg VALUE 'C'.    " Scale basis indicator


  DATA : li_tline  TYPE TABLE OF tline , " SAPscript: Text Lines
         lwa_tline TYPE tline.          " SAPscript: Text Lines

  TYPES : BEGIN OF lty_knvv,
            kunnr TYPE    kunnr, " Customer Number
            vkorg TYPE    vkorg, " Sales Organization
            vtweg TYPE    vtweg, " Distribution Channel
            spart TYPE    spart, " Division
            kdgrp TYPE    kdgrp, " Customer group
            kvgr1 TYPE   kvgr1,  " Customer group 1
            kvgr2 TYPE   kvgr2,  " Customer group 2
          END OF lty_knvv.

  TYPES : BEGIN OF lty_kna1_temp,
            vkorg TYPE    vkorg, " Sales Organization
            vtweg TYPE    vtweg, " Distribution Channel
            kunnr TYPE    kunnr, " Customer Number
          END OF lty_kna1_temp.

  DATA : li_kna1_temp  TYPE TABLE OF lty_kna1_temp,
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
         li_kna1_tmp   TYPE STANDARD TABLE OF lty_kna1_temp, " local internal table
         li_fdtl       TYPE STANDARD TABLE OF ty_fdtl, " local internal table
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
         lwa_kna1_temp TYPE lty_kna1_temp.

  DATA : li_knvv  TYPE TABLE OF lty_knvv,
         lv_count TYPE int2.
  FIELD-SYMBOLS : <lfs_knvv> TYPE lty_knvv.
*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
  TYPES : BEGIN OF lty_kna1 ,
            kunnr TYPE   kunnr,    " Customer Number
            land1 TYPE   land1_gp, " Country Key
            name1 TYPE   name1_gp, " Name 1
            ort01 TYPE   ort01_gp, " City
            pstlz TYPE   pstlz,    " Postal Code
            regio TYPE   regio,    " Region (State, Province, County)
            kukla TYPE   kukla,    " Customer classification
          END OF lty_kna1 .


  TYPES : BEGIN OF lty_comm_group,
            vkorg    TYPE    vkorg,     " Sales Organization
            vtweg    TYPE    vtweg,     " Distribution Channel
            spart    TYPE    spart,     " Division
            provg    TYPE    provg,     " Commission group
            zcount   TYPE    zcount,    " Counter
            partrole TYPE   zpart_role, " Partner Role
          END OF lty_comm_group.

  TYPES : BEGIN OF lty_mvke ,
            matnr TYPE matnr, " Material Number
            vkorg TYPE vkorg, " Sales Organization
            vtweg TYPE vtweg, " Distribution Channel
            provg TYPE provg, " Commission group
          END OF lty_mvke.

  DATA : li_srep     TYPE TABLE OF lty_territ_assn,
         lwa_srep    TYPE lty_territ_assn,
         li_comm_grp TYPE TABLE OF lty_comm_group,
*         lwa_comm_grp TYPE lty_comm_group ,
         li_mvke     TYPE TABLE OF lty_mvke,
*         lwa_mvke TYPE lty_mvke,
         li_kna1     TYPE TABLE OF lty_kna1,
         lwa_kna1    TYPE lty_kna1,
         lv_non_srep TYPE flag. " Sales Rep flag "++D3 COE Defect 2479

*--> Begin of Insert D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
  DATA : li_srep_copy TYPE STANDARD TABLE OF lty_territ_assn.
*<-- End of Insert D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.


  TYPES : BEGIN OF lty_konw,
            knumh TYPE knumh,   " Condition record number
            kopos TYPE kopos,  " Sequential number of the condition
            klfn1 TYPE  klfn1, " Current number of the line scale
            kstbw TYPE kstbw,   " Scale value
            kbetr TYPE kbetr,   " Rate (condition amount or percentage)
          END OF lty_konw,
* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
          BEGIN OF lty_konm,
            knumh TYPE knumh,   " Condition record number
            kopos TYPE kopos,  " Sequential number of the condition
            klfn1 TYPE  klfn1, " Current number of the line scale
            kstbm TYPE kstbm,  " Scale value
            kbetr TYPE kbetr,  " Rate (condition amount or percentage)
          END OF lty_konm,
          lty_t_konm TYPE STANDARD TABLE OF lty_konm,
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN
          BEGIN OF lty_makt,
            matnr TYPE matnr, " Material Number
            maktx TYPE maktx, " Material Description (Short Text)
          END OF lty_makt,

          BEGIN OF lty_mara,
            matnr TYPE matnr, " Material Number
          END OF lty_mara.

  DATA : li_konw  TYPE STANDARD TABLE OF lty_konw INITIAL SIZE 0,
         li_mara  TYPE STANDARD TABLE OF lty_mara INITIAL SIZE 0,
         li_makt  TYPE STANDARD TABLE OF lty_makt INITIAL SIZE 0,
         lwa_mara TYPE lty_mara,
         li_konm  TYPE lty_t_konm. "++D3 COE Defect 2479

  FIELD-SYMBOLS : <lfs_konw> TYPE lty_konw,
                  <lfs_makt> TYPE lty_makt,
                  <lfs_konm> TYPE lty_konm. "++D3 COE Defect 2479

*  DATA :  lv_datbi_low TYPE char10,  " Datbi_low of type CHAR10
*          lv_datbi_high TYPE char10. " Datbi_high of type CHAR10
** End   of Change for Defect#913 by SAGARWA1

  DATA : li_konh  TYPE TABLE OF lty_konh,
         lwa_konh TYPE lty_konh.

  DATA : lv_idx TYPE i. " Idx of type Integers
  DATA : lv_offset TYPE string .


  DATA :li_konp TYPE TABLE OF ty_konp.
  FIELD-SYMBOLS : <lfs_konp> TYPE ty_konp.
  DATA : li_scale TYPE TABLE OF ty_scale.
  DATA : lwa_scale TYPE ty_scale.
  DATA : lv_knega TYPE knega, " Plus/minus sign of the condition amount
         lv_kzbzg TYPE kzbzg. " Scale basis indicator "++D3 COE Defect 2479.

*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
  CONSTANTS:
    lc_and  TYPE char3    VALUE 'AND', " And of type CHAR3
    lc_brac TYPE char1    VALUE '('.   " Brac of type CHAR1
  DATA:
    lv_del       TYPE boolean, " Del of type CHAR1
    li_mvke_tmp  TYPE STANDARD TABLE OF lty_mvke,
    li_kunnr_tmp TYPE STANDARD TABLE OF lty_territ_assn.
  FIELD-SYMBOLS:
        <lfs_field_val>     TYPE any.
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG

*** Adding additional fields in the where clause.
  CLEAR : wa_clause, wa_where.
  READ TABLE wa_dyns-clauses INTO wa_clause INDEX 1.
  IF sy-subrc EQ 0.
    i_where_add[] = wa_clause-where_tab.
  ENDIF. " IF sy-subrc EQ 0


* Create table for final dynamic where clause.
  IF i_where[] IS NOT INITIAL.
    IF i_where_add[] IS NOT INITIAL.
      CLEAR : wa_where.
      MOVE 'AND' TO wa_where-line.
      APPEND wa_where TO i_where.
    ENDIF. " IF i_where_add[] IS NOT INITIAL
  ENDIF. " IF i_where[] IS NOT INITIAL
  APPEND LINES OF i_where_add TO i_where.

** Begin of Change for Defect#913 by SAGARWA1
  IF p_datab IS NOT INITIAL.
    CLEAR : wa_where.
    CONCATENATE '''' p_datab '''' INTO gv_datab.
    CONCATENATE 'AND' '(' 'DATBI GE ' gv_datab 'AND DATAB LE' gv_datab ')' INTO wa_where-line SEPARATED BY space.
    APPEND wa_where TO i_where.
  ENDIF. " IF p_datab IS NOT INITIAL

  IF s_datbi IS NOT INITIAL.
    CLEAR : wa_where.
    wa_where-line = 'AND ( DATBI IN S_DATBI ) '.
    APPEND wa_where TO i_where.
  ENDIF. " IF s_datbi IS NOT INITIAL
**  End   of Change for Defect#913 by SAGARWA1


* ---> Begin of Delete for D3 COE Defect 2479 by DMOIRAN
* Below select has been commented out to keep only one select from T685A.

**--> Begin of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
** Check if the pricing condition type is of discount type
** T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
*  CLEAR lv_knega.
*  SELECT SINGLE
*                 knega " Plus/minus sign of the condition amount
*            FROM t685a " Conditions: Types: Additional Price Element Data
*            INTO lv_knega
*            WHERE kappl = p_kappl
*            AND   kschl = p_kschl.
*
**<-- End of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
* <--- End    of Delete for D3 COE Defect 2479 by DMOIRAN


* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN

  SELECT SINGLE kappl " Application
                kschl " Condition type
                kzbzg " Scale basis indicator
                knega " Plus/minus sign of the condition amount
                txtgr " Text determination procedure
                tdid  " Text ID for text edit control
           FROM t685a " Conditions: Types: Additional Price Element Data
           INTO lwa_t685a
           WHERE kappl = p_kappl
            AND  kschl = p_kschl.
  IF sy-subrc = 0.
    lv_knega = lwa_t685a-knega.
    lv_kzbzg = lwa_t685a-kzbzg.
  ELSE. " ELSE -> IF sy-subrc = 0
    CLEAR: lv_knega,
           lv_kzbzg.
  ENDIF. " IF sy-subrc = 0

* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN
*---> Begin of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
  IF gv_srep_flag = 'X'.
    IF  s_srep IS NOT INITIAL.
      REFRESH : i_where_new.
      LOOP AT i_where INTO wa_where.
        IF wa_where-line CS 'KUNNR'.
***        Error message.
          MESSAGE 'Do not provide both Sales rep and customer as input' TYPE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF wa_where-line CS 'KUNNR'

        IF wa_where-line CS 'KUNAG'.
***        Error message.
          MESSAGE 'Do not provide both Sales rep and Sold-to-party as input' TYPE 'E'.
*          LEAVE TO SCREEN 1000.
          LEAVE LIST-PROCESSING .
        ENDIF. " IF wa_where-line CS 'KUNAG'


        IF wa_where-line CS 'KUNWE'.
***        Error message.
          MESSAGE 'Do not provide both Sales rep and Ship-to-party as input' TYPE 'E'.
*          LEAVE TO SCREEN 1000.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF wa_where-line CS 'KUNWE'



      ENDLOOP. " LOOP AT i_where INTO wa_where
*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
**** Below code is copied from else condition.This logic is also
* needed here to filter out the data from table zotc_territ_assn.
* Creating dynamic where clause for Sales rep logic.
* Where clause cannot begin with 'AND' hence we are checking, if the internal table 'I_WHERE_NEW'
* is initial, if it is initial, then if we have AND in the record, replace it will space and append to
* 'I_WHERE_NEW'table.
* if the records are with range, it occupies multiple lines in internal table 'I_WHERE'
* Check for open bracket '(' in the next record.
* if there in not open bracket, append the record to internal table 'I_WHERE_NEW'.

      LOOP AT i_where INTO wa_where.
        IF wa_where-line CS c_vkorg.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP lc_and.
              REPLACE FIRST OCCURRENCE OF lc_and IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP lc_and
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF lc_brac IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ELSE. " ELSE -> IF i_where_new IS INITIAL
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF lc_brac IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS c_vkorg

        IF wa_where-line CS c_vtweg.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP lc_and.
              REPLACE FIRST OCCURRENCE OF lc_and IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP lc_and
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF lc_brac IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ELSE. " ELSE -> IF i_where_new IS INITIAL
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF lc_brac IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS c_vtweg
        CLEAR wa_where.
      ENDLOOP. " LOOP AT i_where INTO wa_where
* The duplicate records should  be deleted in the internal table.
* No sort performed as the order of the records in where clause should not be changed.
      DELETE ADJACENT DUPLICATES FROM i_where_new COMPARING line.
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG

      SELECT vkorg        " Sales Organization
             vtweg        " Distribution Channel
             spart        " Division
             kunnr        " Customer Number
             territory_id " Partner Territory ID
             partrole     " Partner Role
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
             effective_from " Effective From
             effective_to   " Effective To
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
        FROM zotc_territ_assn " Comm Group: Territory Assignment
        INTO TABLE li_srep
        WHERE
*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
        (i_where_new) AND
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
         territory_id IN s_srep.
* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
* If there is no record then clear out the sales rep flag.
      IF sy-subrc NE 0.
        CLEAR gv_srep_flag.
      ENDIF. " IF sy-subrc NE 0
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN
    ELSE. " ELSE -> IF s_srep IS NOT INITIAL

* Creating dynamic where clause for Sales rep logic.
* Where clause cannot begin with 'AND' hence we are checking, if the internal table 'I_WHERE_NEW'
* is initial, if it is initial, then if we have AND in the record, replace it will space and append to
* 'I_WHERE_NEW'table.
* if the records are with range, it occupies multiple lines in internal table 'I_WHERE'
* Check for open bracket '(' in the next record.
* if there in not open bracket, append the record to internal table 'I_WHERE_NEW'.


      LOOP AT i_where INTO wa_where.
        IF wa_where-line CS 'VKORG'.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP 'AND'.
              REPLACE FIRST OCCURRENCE OF 'AND' IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP 'AND'
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ELSE. " ELSE -> IF i_where_new IS INITIAL
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS 'VKORG'

        IF wa_where-line CS 'VTWEG'.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP 'AND'.
              REPLACE FIRST OCCURRENCE OF 'AND' IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP 'AND'
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ELSE. " ELSE -> IF i_where_new IS INITIAL
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS 'VTWEG'

        IF wa_where-line CS 'KUNNR'.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP 'AND'.
              REPLACE FIRST OCCURRENCE OF 'AND' IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP 'AND'
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ELSE. " ELSE -> IF i_where_new IS INITIAL
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS 'KUNNR'

        IF wa_where-line CS 'KUNAG'.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            REPLACE ALL OCCURRENCES OF 'KUNAG' IN wa_where-line WITH 'KUNNR'.
*            REPLACE ALL OCCURRENCES OF 'AND' IN wa_where-line WITH space.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP 'AND'.
              REPLACE FIRST OCCURRENCE OF 'AND' IN wa_where-line WITH space.

            ENDIF. " IF lv_offset CP 'AND'
*            REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
*            REPLACE ALL OCCURRENCES OF ')' IN wa_where-line WITH space.
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
                REPLACE ALL OCCURRENCES OF 'KUNAG' IN wa_where-line WITH 'KUNNR'.
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ELSE. " ELSE -> IF i_where_new IS INITIAL
            REPLACE ALL OCCURRENCES OF 'KUNAG' IN wa_where-line WITH 'KUNNR'.
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
                REPLACE ALL OCCURRENCES OF 'KUNAG' IN wa_where-line WITH 'KUNNR'.
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS 'KUNAG'

        IF wa_where-line CS 'KUNWE'.
          lv_idx = sy-tabix .
          lv_idx = lv_idx + 1.
          IF i_where_new IS INITIAL.
            REPLACE ALL OCCURRENCES OF 'KUNWE' IN wa_where-line WITH 'KUNNR'.
            lv_offset = wa_where-line+0(4).
            IF lv_offset CP 'AND'.
              REPLACE FIRST OCCURRENCE OF 'AND' IN wa_where-line WITH space.
            ENDIF. " IF lv_offset CP 'AND'
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                REPLACE ALL OCCURRENCES OF 'KUNWE' IN wa_where-line WITH 'KUNNR'.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ELSE. " ELSE -> IF i_where_new IS INITIAL
            REPLACE ALL OCCURRENCES OF 'KUNWE' IN wa_where-line WITH 'KUNNR'.
            APPEND wa_where TO i_where_new.
            READ TABLE i_where INTO wa_where INDEX lv_idx.
            IF sy-subrc IS INITIAL.
              REPLACE ALL OCCURRENCES OF '(' IN wa_where-line WITH space.
              IF sy-subrc IS NOT INITIAL.
                REPLACE ALL OCCURRENCES OF 'KUNWE' IN wa_where-line WITH 'KUNNR'.
                APPEND wa_where TO i_where_new.
              ENDIF. " IF sy-subrc IS NOT INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF i_where_new IS INITIAL
          CONTINUE.
        ENDIF. " IF wa_where-line CS 'KUNWE'

      ENDLOOP. " LOOP AT i_where INTO wa_where

*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH

* The duplicate records should  be deleted in the internal table.
* No sort performed as the order of the records in where clause should not be changed.
      DELETE ADJACENT DUPLICATES FROM i_where_new COMPARING line.

*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH

      IF i_where_new IS NOT INITIAL.
        SELECT vkorg        " Sales Organization
               vtweg        " Distribution Channel
               spart        " Division
               kunnr        " Customer Number
               territory_id " Partner Territory ID
               partrole     " Partner Role
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
               effective_from " Effective From
               effective_to   " Effective To
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
          FROM zotc_territ_assn " Comm Group: Territory Assignment
          INTO TABLE li_srep
          WHERE (i_where_new).
* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
* If there is no record then clear out the sales rep flag.
        IF sy-subrc NE 0.
          CLEAR gv_srep_flag.
        ENDIF. " IF sy-subrc NE 0
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN


      ENDIF. " IF i_where_new IS NOT INITIAL
    ENDIF. " IF s_srep IS NOT INITIAL
*    IF sy-subrc IS INITIAL.

*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
    REFRESH li_srep_copy.
    li_srep_copy = li_srep.
    SORT li_srep_copy BY vkorg vtweg spart partrole .
    DELETE ADJACENT DUPLICATES FROM li_srep_copy COMPARING vkorg vtweg spart partrole.
    IF li_srep_copy IS NOT INITIAL.
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.

      SELECT  vkorg          " Sales Organization
              vtweg          " Distribution Channel
              spart          " Division
              provg          " Commission group
              zcount         " Counter
              partrole       " Partner Role
        FROM zotc_comm_group " Comm Group: XREF Commission Group to Partner Role
        INTO TABLE li_comm_grp
*--> Begin of Change for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
*        FOR ALL ENTRIES IN li_srep
        FOR ALL ENTRIES IN li_srep_copy
*<-- End of Change for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH
         WHERE vkorg = li_srep_copy-vkorg
        AND   vtweg = li_srep_copy-vtweg
        AND   spart = li_srep_copy-spart
        AND partrole =  li_srep_copy-partrole.
      IF sy-subrc IS INITIAL.

*--> Begin of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH

        SORT li_comm_grp.
        DELETE ADJACENT DUPLICATES FROM li_comm_grp COMPARING ALL FIELDS.
        IF li_comm_grp IS NOT INITIAL        .
*<-- End of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
          SELECT matnr " Material Number
                 vkorg " Sales Organization
                 vtweg " Distribution Channel
                 provg " Commission group
            FROM mvke  " Sales Data for Material
            INTO TABLE li_mvke
            FOR ALL ENTRIES IN li_comm_grp
            WHERE vkorg = li_comm_grp-vkorg
            AND   vtweg = li_comm_grp-vtweg
            AND   provg = li_comm_grp-provg.
        ENDIF. " IF li_comm_grp IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_srep_copy IS NOT INITIAL


*--> Begin of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
    REFRESH li_srep_copy.
    li_srep_copy = li_srep.
    SORT li_srep_copy BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_srep_copy COMPARING kunnr.
    IF li_srep_copy IS NOT INITIAL.
*<-- End of insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.

      SELECT  kunnr " Customer Number
              land1 " Country Key
              name1 " Name 1
              ort01 " City
              pstlz " Postal Code
              regio " Region (State, Province, County)
              kukla " Customer classification
        FROM kna1   " General Data in Customer Master
        INTO TABLE li_kna1
*--> Begin of Change for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
*      FOR ALL ENTRIES IN li_srep
        FOR ALL ENTRIES IN li_srep_copy
*<-- End of Change for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
        WHERE kunnr = li_srep_copy-kunnr.

      IF li_kna1 IS NOT INITIAL.
        SELECT kunnr " Customer Number
               vkorg " Sales Organization
               vtweg " Distribution Channel
               spart " Division
               kdgrp " Customer group
               kvgr1 " Customer group 1
               kvgr2 " Customer group 2
          FROM knvv  " Customer Master Sales Data
          INTO TABLE li_knvv
          FOR ALL ENTRIES IN li_kna1
          WHERE kunnr = li_kna1-kunnr.
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*&-- There is a READ done on table li_knvv using BINARY SEARCH in the code later
* but this SORT was missing .
        SORT li_knvv BY kunnr vkorg vtweg.
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019

      ENDIF. " IF li_kna1 IS NOT INITIAL
    ENDIF. " IF li_srep_copy IS NOT INITIAL
  ENDIF. " IF gv_srep_flag = 'X'
*<--- End of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.

***   fetch the required data from the valid condition table, using the dynamic where clause .
  IF i_where[] IS NOT INITIAL.
    SELECT * FROM (gv_table)
    INTO CORRESPONDING FIELDS OF TABLE <gfs_tab_temp1>
    WHERE (i_where).

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e134 . " Data Not Found !!
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF i_where[] IS NOT INITIAL

*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
  IF s_srep[] IS NOT INITIAL.
    FREE li_mvke_tmp[].
    li_mvke_tmp[] = li_mvke[].
    SORT li_mvke_tmp BY vkorg vtweg matnr.
    DELETE ADJACENT DUPLICATES FROM li_mvke_tmp COMPARING vkorg vtweg matnr.

    FREE li_kunnr_tmp[].
    li_kunnr_tmp[] = li_srep[].
    SORT li_kunnr_tmp BY vkorg vtweg kunnr.
    DELETE ADJACENT DUPLICATES FROM li_kunnr_tmp COMPARING vkorg vtweg kunnr.

    SORT li_srep_copy  BY vkorg vtweg kunnr.

*Temp table for further use
    IF <gfs_tab_temp1> IS ASSIGNED.
      APPEND LINES OF <gfs_tab_temp1> TO <gfs_tab_temp_srep>.
    ENDIF. " IF <gfs_tab_temp1> IS ASSIGNED

    IF <gfs_tab_temp_srep> IS ASSIGNED.
      LOOP AT <gfs_tab_temp_srep> ASSIGNING <gfs_row>.

        CLEAR lv_del.
        ASSIGN COMPONENT c_vkorg OF STRUCTURE <gfs_row> TO <gfs_desc>.
        ASSIGN COMPONENT c_vtweg OF STRUCTURE <gfs_row> TO <gfs_fld>.
        ASSIGN COMPONENT c_kunnr OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
        ASSIGN COMPONENT c_matnr OF STRUCTURE  <gfs_row> TO <lfs_field_val>.
        IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED .
          READ TABLE li_srep_copy WITH KEY  vkorg = <gfs_desc>
                                            vtweg = <gfs_fld>
                                            kunnr = <gfs_rdesc>
                                            BINARY SEARCH
                                            TRANSPORTING NO FIELDS.
          IF sy-subrc IS NOT INITIAL.
            DELETE TABLE <gfs_tab_temp1> FROM <gfs_row>.
            lv_del = abap_true.
          ENDIF. " IF sy-subrc IS NOT INITIAL
        ENDIF. " IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED

        IF lv_del = abap_false.
          IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <lfs_field_val> IS ASSIGNED .
            READ TABLE li_mvke_tmp WITH KEY  vkorg = <gfs_desc>
                                             vtweg = <gfs_fld>
                                             matnr = <lfs_field_val>
                                             BINARY SEARCH
                                             TRANSPORTING NO FIELDS.
            IF sy-subrc IS NOT INITIAL.
              DELETE TABLE <gfs_tab_temp1> FROM <gfs_row>.
            ENDIF. " IF sy-subrc IS NOT INITIAL
          ENDIF. " IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <lfs_field_val> IS ASSIGNED
        ENDIF. " IF lv_del = abap_false
      ENDLOOP. " LOOP AT <gfs_tab_temp_srep> ASSIGNING <gfs_row>
    ENDIF. " if <gfs_tab_temp_srep> is ASSIGNED
  ENDIF. " IF s_srep[] IS NOT INITIAL
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG

** Update the field and table name .
  SELECT tabname   " Table Name
         fieldname " Field Name
         as4local  " Activation Status of a Repository Object
         as4vers   " Version of the entry (not used)
         position  " Position of the field in the table
         rollname  " Data element (semantic domain)
    FROM dd03l     " Table Fields
    INTO TABLE i_dd03l
    WHERE tabname = gv_table .
  IF sy-subrc IS INITIAL.

    LOOP AT i_dd03l INTO wa_dd03l .
      wa_fdtl-tabname =  wa_dd03l-tabname.
      wa_fdtl-fieldname = wa_dd03l-fieldname.
      wa_fdtl-rollname = wa_dd03l-rollname.
      APPEND wa_fdtl TO i_fdtl.
*  wa_fdtl-SCRTEXT_L
    ENDLOOP. " LOOP AT i_dd03l INTO wa_dd03l
  ENDIF. " IF sy-subrc IS INITIAL


*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
*  IF gv_srep_flag <> 'X'.

  LOOP AT  <gfs_tab_temp1> ASSIGNING <gfs_row>.

    IF gv_srep_flag <> 'X'.
      ASSIGN COMPONENT 'VKORG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED .
        lwa_kna1_temp-vkorg = <gfs_fld>.
        UNASSIGN <gfs_fld>.
      ENDIF. " IF <gfs_fld> IS ASSIGNED

      ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED.
        lwa_kna1_temp-vtweg = <gfs_fld>.
        UNASSIGN <gfs_fld>.
      ENDIF. " IF <gfs_fld> IS ASSIGNED

      ASSIGN COMPONENT c_kunnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED.
        lwa_kna1_temp-kunnr = <gfs_fld>.
        APPEND lwa_kna1_temp TO li_kna1_temp.
      ELSE. " ELSE -> IF <gfs_fld> IS ASSIGNED

        ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
        IF <gfs_fld> IS ASSIGNED.
          lwa_kna1_temp-kunnr = <gfs_fld>.
          APPEND lwa_kna1_temp TO li_kna1_temp.
        ENDIF. " IF <gfs_fld> IS ASSIGNED
      ENDIF. " IF <gfs_fld> IS ASSIGNED

    ENDIF.
*&-- Begin of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
    ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF sy-subrc EQ 0.
      CLEAR : lwa_konh.
      MOVE <gfs_fld> TO lwa_konh-knumh.
      APPEND lwa_konh TO li_konh.
    ENDIF. " IF sy-subrc EQ 0

** Begin of Change for Defect#913 by SAGARWA1
***  Fetch Material to get Material Description.
    CLEAR lwa_mara.
    ASSIGN COMPONENT c_matnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF sy-subrc EQ 0.
      MOVE <gfs_fld> TO lwa_mara-matnr.
      APPEND lwa_mara TO li_mara.
    ENDIF. " IF sy-subrc EQ 0
** End   of Change for Defect#913 by SAGARWA1


** Begin u103062
*    ENDIF. "if sy-tabix = 1
** End u103062
*&-- End of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

  ENDLOOP. " LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>

  IF gv_srep_flag <> 'X'.
    IF li_kna1_temp IS NOT INITIAL.
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*&-- Deleting duplicate entries before data selection.
      li_kna1_tmp[] = li_kna1_temp[].
      SORT li_kna1_tmp BY kunnr.
      DELETE ADJACENT DUPLICATES FROM li_kna1_tmp COMPARING kunnr.

*&-- Sort and delete duplicate entries.
      SORT li_kna1_temp BY kunnr vkorg vtweg.
      DELETE ADJACENT DUPLICATES FROM li_kna1_temp COMPARING ALL FIELDS.
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019

      SELECT  kunnr " Customer Number
              land1 " Country Key
              name1 " Name 1
              ort01 " City
              pstlz " Postal Code
              regio " Region (State, Province, County)
              kukla " Customer classification
        FROM kna1   " General Data in Customer Master
        INTO TABLE li_kna1
*&-- Begin of delete for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*        FOR ALL ENTRIES IN li_kna1_temp
*        WHERE kunnr = li_kna1_temp-kunnr.
*&-- End of delete for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
        FOR ALL ENTRIES IN li_kna1_tmp
        WHERE kunnr = li_kna1_tmp-kunnr.
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019

      SELECT kunnr " Customer Number
             vkorg " Sales Organization
             vtweg " Distribution Channel
             spart " Division
             kdgrp " Customer group
             kvgr1 " Customer group 1
             kvgr2 " Customer group 2
        FROM knvv  " Customer Master Sales Data
        INTO TABLE li_knvv
        FOR ALL ENTRIES IN li_kna1_temp
        WHERE kunnr = li_kna1_temp-kunnr
        AND   vkorg = li_kna1_temp-vkorg
        AND   vtweg = li_kna1_temp-vtweg.

      SORT li_knvv BY kunnr vkorg vtweg.
    ENDIF. " IF li_kna1_temp IS NOT INITIAL

  ENDIF. " IF gv_srep_flag <> 'X'
*<-- End of Addition for D2_OTC_RDD_00028/Defect 1191 by VCHOUDH.

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
* Sort Territory Assignment for the latest date
  SORT li_srep BY vkorg vtweg kunnr ASCENDING
                  effective_from DESCENDING.
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1


*--> Begin of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.

* ---> Begin of Delete for D3 COE Defect 2479 by DMOIRAN
* Below code has been commented out as the logic is not working.
*
*    IF gv_srep_flag = 'X'.
*      LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>.
*        UNASSIGN <gfs_desc>.
*        UNASSIGN <gfs_fld>.
*        UNASSIGN <gfs_rdesc>.
*        ASSIGN COMPONENT 'VKORG' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*        ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*        ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
*        IF <gfs_rdesc> IS NOT ASSIGNED.
*          ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
*        ENDIF. " IF <gfs_rdesc> IS NOT ASSIGNED
*        IF <gfs_rdesc> IS NOT ASSIGNED.
*          ASSIGN COMPONENT 'KUNWE' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
*        ENDIF. " IF <gfs_rdesc> IS NOT ASSIGNED
*        IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED .
*          READ TABLE li_srep INTO lwa_srep WITH KEY vkorg = <gfs_desc>
*                                                  vtweg = <gfs_fld>
*                                                  kunnr = <gfs_rdesc>
**& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
*                                                  BINARY SEARCH.
**& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
*
*          IF sy-subrc IS INITIAL.
*            ASSIGN COMPONENT 'KUNN2' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*            <gfs_desc> = lwa_srep-territory_id.
*            UNASSIGN <gfs_desc>.
*
*            READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_srep-kunnr .
*            IF sy-subrc IS INITIAL.
*              UNASSIGN <gfs_desc>.
*              ASSIGN COMPONENT 'ORT01' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*              IF <gfs_desc> IS ASSIGNED .
*                <gfs_desc> = lwa_kna1-ort01.
*              ENDIF. " IF <gfs_desc> IS ASSIGNED
*              UNASSIGN <gfs_desc>.
*              ASSIGN COMPONENT 'LAND1' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*              IF <gfs_desc> IS ASSIGNED.
*                <gfs_desc> = lwa_kna1-land1.
*                UNASSIGN <gfs_desc>.
*              ENDIF. " IF <gfs_desc> IS ASSIGNED
**--> Begin of Addition for D2_OTC_RDD_0028/ Defect 1191 by VCHOUDH.
*              UNASSIGN <gfs_desc>.
*              ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_desc>.
*              IF <gfs_desc> IS ASSIGNED.
*                <gfs_desc> = lwa_kna1-kukla.
*              ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*
*
*              READ TABLE li_knvv ASSIGNING <lfs_knvv> WITH KEY kunnr = lwa_kna1-kunnr
*                                                               vkorg = lwa_srep-vkorg
*                                                               vtweg = lwa_srep-vtweg.
*              IF sy-subrc IS INITIAL.
*                UNASSIGN <gfs_desc>.
*                ASSIGN COMPONENT c_zzkvgr1 OF STRUCTURE <gfs_row> TO <gfs_desc>.
*                IF <gfs_desc> IS ASSIGNED .
*                  <gfs_desc> = <lfs_knvv>-kvgr1.
*                  UNASSIGN <gfs_desc>.
*                ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*                ASSIGN COMPONENT c_zzkvgr2 OF STRUCTURE <gfs_row> TO <gfs_desc>.
*                IF <gfs_desc> IS ASSIGNED.
*                  <gfs_desc> = <lfs_knvv>-kvgr2.
*                  UNASSIGN <gfs_desc>.
*                ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*                ASSIGN COMPONENT c_kdgrp OF STRUCTURE <gfs_row> TO <gfs_desc>.
*                IF <gfs_desc> IS ASSIGNED.
*                  <gfs_desc> = <lfs_knvv>-kdgrp.
*                  UNASSIGN <gfs_desc>.
*                ENDIF. " IF <gfs_desc> IS ASSIGNED
*              ENDIF. " IF sy-subrc IS INITIAL
**<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
*
*              UNASSIGN <gfs_desc>.
*              ASSIGN COMPONENT 'PSTLZ' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*              IF <gfs_desc> IS ASSIGNED.
*                <gfs_desc> = lwa_kna1-pstlz.
*                UNASSIGN <gfs_desc>.
*              ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*              UNASSIGN <gfs_desc>.
*              ASSIGN COMPONENT 'REGIO' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*              IF <gfs_desc> IS ASSIGNED .
*                <gfs_desc> = lwa_kna1-regio.
*                UNASSIGN <gfs_desc>.
*              ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*
*              wa_fdtl-tabname =  'KNA1'.
*              wa_fdtl-fieldname = 'ORT01'.
*              wa_fdtl-rollname = 'ORT01_GP'.
*              APPEND wa_fdtl TO i_fdtl.
*
*
*              wa_fdtl-tabname =  'KNA1'.
*              wa_fdtl-fieldname = 'LAND1'.
*              wa_fdtl-rollname = 'LAND1_GP'.
*              APPEND wa_fdtl TO i_fdtl.
*
*              wa_fdtl-tabname =  'KNA1'.
*              wa_fdtl-fieldname = 'PSTLZ'.
*              wa_fdtl-rollname = 'PSTLZ'.
*              APPEND wa_fdtl TO i_fdtl.
*
*              wa_fdtl-tabname =  'KNA1'.
*              wa_fdtl-fieldname = 'REGIO'.
*              wa_fdtl-rollname = 'REGIO'.
*              APPEND wa_fdtl TO i_fdtl.
*
*              wa_fdtl-tabname = 'KNA1'.
*              wa_fdtl-fieldname = 'KUKLA'.
*              wa_fdtl-rollname = 'KUKLA'.
*            ENDIF. " IF sy-subrc IS INITIAL
*
*            MOVE-CORRESPONDING <gfs_row> TO <gfs_row_temp>.
*            APPEND <gfs_row_temp> TO <gfs_tab> .
*          ENDIF. " IF sy-subrc IS INITIAL
*        ENDIF. " IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED
*      ENDLOOP. " LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>
*    ELSE. " ELSE -> IF gv_srep_flag = 'X'
*
*      LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>.
*        UNASSIGN <gfs_fld>.
*        ASSIGN COMPONENT c_kunnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
*        IF <gfs_fld> IS NOT ASSIGNED .
*          UNASSIGN <gfs_fld>.
*          ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*
*        ENDIF. " IF <gfs_fld> IS NOT ASSIGNED
*        IF <gfs_fld> IS ASSIGNED.
*          CLEAR : lwa_kna1.
*          READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <gfs_fld>.
*          IF sy-subrc IS INITIAL.
*            UNASSIGN <gfs_desc>.
*            ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_desc>.
*            IF <gfs_desc> IS ASSIGNED.
*              <gfs_desc> = lwa_kna1-kukla.
*            ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*          ENDIF. " IF sy-subrc IS INITIAL
*
*
*          READ TABLE li_knvv ASSIGNING <lfs_knvv> WITH KEY kunnr = <gfs_fld>.
*
*          IF sy-subrc IS INITIAL.
*            UNASSIGN <gfs_desc>.
*            ASSIGN COMPONENT c_zzkvgr1 OF STRUCTURE <gfs_row> TO <gfs_desc>.
*            IF <gfs_desc> IS ASSIGNED .
*              <gfs_desc> = <lfs_knvv>-kvgr1.
*              UNASSIGN <gfs_desc>.
*            ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*
*            ASSIGN COMPONENT c_zzkvgr2 OF STRUCTURE <gfs_row> TO <gfs_desc>.
*            IF <gfs_desc> IS ASSIGNED.
*              <gfs_desc> = <lfs_knvv>-kvgr2.
*              UNASSIGN <gfs_desc>.
*            ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*            ASSIGN COMPONENT c_kdgrp OF STRUCTURE <gfs_row> TO <gfs_desc>.
*            IF <gfs_desc> IS ASSIGNED.
*              <gfs_desc> = <lfs_knvv>-kdgrp.
*              UNASSIGN <gfs_desc>.
*            ENDIF. " IF <gfs_desc> IS ASSIGNED
*          ENDIF. " IF sy-subrc IS INITIAL
*
*        ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*        wa_fdtl-tabname = 'KNA1'.
*        wa_fdtl-fieldname = 'KUKLA'.
*        wa_fdtl-rollname = 'KUKLA'.
*
*        MOVE-CORRESPONDING <gfs_row> TO <gfs_row_temp>.
*        APPEND <gfs_row_temp> TO <gfs_tab> .
*
*      ENDLOOP. " LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>
*    ENDIF. " IF gv_srep_flag = 'X'
** <--- End    of Delete for D3 COE Defect 2479 by DMOIRAN
*
* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
*The above logic has been written again. The issue in above
* code is that it picks up only Sale Rep records when it is run
* for all customers and hence records for non-sales rep is not
* displayed.

  IF li_konh IS NOT INITIAL.
*    Fetch the condition record details from KONP table .

*&-- Begin of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
    SORT li_konh BY knumh.
    DELETE ADJACENT DUPLICATES FROM li_konh COMPARING knumh.
*&-- End of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

    SELECT knumh " Condition record number
           kopos " Sequential number of the condition
           kappl " Application
           kschl " Condition type
           stfkz " Scale Type
           kzbzg " Scale basis indicator
           kstbm " Condition scale quantity
           konws " Scale currency
           kbetr " Rate (condition amount or percentage) where no scale exists
** Begin of Change for Defect#913 by SAGARWA1
           konwa " Rate unit (currency or percentage)
** End   of Change for Defect#913 by SAGARWA1
           kpein    " Condition pricing unit
           kmein    " Condition unit
           prsch    " Scale Group
           kwaeh
           loevm_ko " Deletion Indicator for Condition Item
      FROM konp     " Conditions (Item)
      INTO TABLE li_konp
      FOR ALL ENTRIES IN li_konh
      WHERE knumh = li_konh-knumh
      AND   kappl = p_kappl
      AND   kschl = p_kschl.


    SELECT tabname   " Table Name
           fieldname " Field Name
           as4local  " Activation Status of a Repository Object
           as4vers   " Version of the entry (not used)
           position  " Position of the field in the table
           rollname  " Data element (semantic domain)
      FROM dd03l     " Table Fields
      INTO TABLE i_dd03l
      WHERE tabname = c_konp.

    LOOP AT i_dd03l INTO wa_dd03l .
      wa_fdtl-tabname =  wa_dd03l-tabname.
      wa_fdtl-fieldname = wa_dd03l-fieldname.
      wa_fdtl-rollname = wa_dd03l-rollname.
      APPEND wa_fdtl TO i_fdtl.
    ENDLOOP. " LOOP AT i_dd03l INTO wa_dd03l
  ENDIF.
*&-- Begin of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
  SORT li_konp BY knumh.
** Begin of Change for Defect#913 by SAGARWA1
***  Fetch Material Description.
  IF li_mara[] IS NOT INITIAL.
    SORT li_mara BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_mara COMPARING matnr.
    SELECT matnr " Material Number
           maktx " Material Description (Short Text)
      FROM makt  " Material Descriptions
      INTO TABLE li_makt
      FOR ALL ENTRIES IN li_mara
      WHERE matnr = li_mara-matnr
      AND   spras = sy-langu.
    IF sy-subrc = 0.
      SORT li_makt BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_mara[] IS NOT INITIAL
*&-- End of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

  LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>.

* BOC   INC0524176-01
    IF sy-tabix = 1.
      lv_count  = 1.
    ELSE.
      CLEAR lv_count.
    ENDIF.
* EOC   INC0524176-01
*&-- Begin of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
    ASSIGN COMPONENT c_matnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
    READ TABLE li_makt ASSIGNING <lfs_makt> WITH KEY matnr = <gfs_fld>
                                       BINARY SEARCH.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'MATNR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      MOVE <lfs_makt>-maktx TO <gfs_desc>.
      UNASSIGN <gfs_desc>.
    ENDIF. " IF sy-subrc = 0

    ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_fld>.

    ASSIGN COMPONENT c_counter OF STRUCTURE <gfs_row> TO <gfs_desc>.
    MOVE '0' TO <gfs_desc>.
    UNASSIGN <gfs_desc>.


    ASSIGN COMPONENT c_kotabnr OF STRUCTURE <gfs_row> TO <gfs_desc>.
    MOVE p_tab TO <gfs_desc>.
    UNASSIGN <gfs_desc>.


    READ TABLE li_konp ASSIGNING <lfs_konp> WITH KEY knumh = <gfs_fld> BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      ASSIGN COMPONENT c_loevm_ko OF STRUCTURE <gfs_row> TO <gfs_desc>.
      MOVE <lfs_konp>-loevm_ko TO <gfs_desc>.
      UNASSIGN <gfs_desc>.
      ASSIGN COMPONENT c_kmein OF STRUCTURE <gfs_row> TO <gfs_desc>.
      MOVE <lfs_konp>-kmein TO <gfs_desc>.
      UNASSIGN <gfs_desc>.
      ASSIGN COMPONENT c_kpein OF STRUCTURE <gfs_row> TO <gfs_desc>.
      MOVE <lfs_konp>-kpein TO <gfs_desc>.
      UNASSIGN <gfs_desc>.
*        ** Begin of Change for Defect#913 by SAGARWA1
* Add Currency value
      ASSIGN COMPONENT c_konwa OF STRUCTURE <gfs_row> TO <gfs_desc>.
      MOVE <lfs_konp>-konwa TO <gfs_desc>.
      UNASSIGN <gfs_desc>.
** End   of Change for Defect#913 by SAGARWA1
      ASSIGN COMPONENT c_kbetr OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <lfs_konp>-konwa = '%'.
        COMPUTE <lfs_konp>-kbetr = <lfs_konp>-kbetr / 10.
      ENDIF. " IF <lfs_konp>-konwa = '%'
*--> Begin of insert for D2_OTC_RDD_0028 / Defect 1264 by VCHOUDH.
* Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
      IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0.00'.
        <lfs_konp>-kbetr = <lfs_konp>-kbetr * -1.
        MOVE <lfs_konp>-kbetr TO <gfs_desc>.
      ELSE. " ELSE -> IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
        MOVE <lfs_konp>-kbetr TO <gfs_desc>.
*--> Begin of insert for D2_OTC_RDD_0028 / Defect 1264 by VCHOUDH.
      ENDIF. " IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
      UNASSIGN <gfs_desc>.

      ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_desc>.
*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.

      CLEAR lv_name.
      CONCATENATE <gfs_desc> <lfs_konp>-kopos INTO lv_name.

      lv_obj = lc_konp.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = lwa_t685a-tdid
          language                = sy-langu
          name                    = lv_name
          object                  = lv_obj
        TABLES
          lines                   = li_tline
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        UNASSIGN <gfs_desc>.
        ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
        IF <gfs_desc> IS ASSIGNED .
          <gfs_desc> = 'N'.
        ENDIF. " IF <gfs_desc> IS ASSIGNED
      ELSE. " ELSE -> IF sy-subrc <> 0
        UNASSIGN <gfs_desc>.
        READ TABLE li_tline INTO lwa_tline INDEX 1.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = 'Y'.
          ENDIF. " IF <gfs_desc> IS ASSIGNED
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT c_record_txt OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = lwa_tline-tdline.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED
        ELSE. " ELSE -> IF sy-subrc IS INITIAL

          ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = 'N'.
          ENDIF. " IF <gfs_desc> IS ASSIGNED

        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF sy-subrc <> 0
*<-- End of Addition for D2_OTC_RDD_00028/Defect 1191 by VCHOUDH.
    ENDIF. " IF sy-subrc IS INITIAL

*&-- End of insert for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

    CLEAR lv_non_srep.
**********
    UNASSIGN <gfs_desc>.
    UNASSIGN <gfs_fld>.
    UNASSIGN <gfs_rdesc>.
    ASSIGN COMPONENT 'VKORG' OF STRUCTURE <gfs_row> TO <gfs_desc>.
    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
    IF <gfs_rdesc> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
    ENDIF. " IF <gfs_rdesc> IS NOT ASSIGNED
    IF <gfs_rdesc> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'KUNWE' OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
    ENDIF. " IF <gfs_rdesc> IS NOT ASSIGNED
    IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED .
      READ TABLE li_srep INTO lwa_srep WITH KEY vkorg = <gfs_desc>
                                              vtweg = <gfs_fld>
                                              kunnr = <gfs_rdesc>
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
                                              BINARY SEARCH.
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

      IF sy-subrc IS INITIAL.
        ASSIGN COMPONENT 'KUNN2' OF STRUCTURE <gfs_row> TO <gfs_desc>.
        <gfs_desc> = lwa_srep-territory_id.
        UNASSIGN <gfs_desc>.

        READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_srep-kunnr .
        IF sy-subrc IS INITIAL.
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT 'ORT01' OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = lwa_kna1-ort01.
          ENDIF. " IF <gfs_desc> IS ASSIGNED
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT 'LAND1' OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = lwa_kna1-land1.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED
*--> Begin of Addition for D2_OTC_RDD_0028/ Defect 1191 by VCHOUDH.
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = lwa_kna1-kukla.
          ENDIF. " IF <gfs_desc> IS ASSIGNED



          READ TABLE li_knvv ASSIGNING <lfs_knvv> WITH KEY kunnr = lwa_kna1-kunnr
                                                           vkorg = lwa_srep-vkorg
                                                           vtweg = lwa_srep-vtweg
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            UNASSIGN <gfs_desc>.
            ASSIGN COMPONENT c_zzkvgr1 OF STRUCTURE <gfs_row> TO <gfs_desc>.
            IF <gfs_desc> IS ASSIGNED .
              <gfs_desc> = <lfs_knvv>-kvgr1.
              UNASSIGN <gfs_desc>.
            ENDIF. " IF <gfs_desc> IS ASSIGNED

            ASSIGN COMPONENT c_zzkvgr2 OF STRUCTURE <gfs_row> TO <gfs_desc>.
            IF <gfs_desc> IS ASSIGNED.
              <gfs_desc> = <lfs_knvv>-kvgr2.
              UNASSIGN <gfs_desc>.
            ENDIF. " IF <gfs_desc> IS ASSIGNED

            ASSIGN COMPONENT c_kdgrp OF STRUCTURE <gfs_row> TO <gfs_desc>.
            IF <gfs_desc> IS ASSIGNED.
              <gfs_desc> = <lfs_knvv>-kdgrp.
              UNASSIGN <gfs_desc>.
            ENDIF. " IF <gfs_desc> IS ASSIGNED
          ENDIF. " IF sy-subrc IS INITIAL
*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.

          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT 'PSTLZ' OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = lwa_kna1-pstlz.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED

          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT 'REGIO' OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = lwa_kna1-regio.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED


        ENDIF. " IF sy-subrc IS INITIAL

*          MOVE-CORRESPONDING <gfs_row> TO <gfs_row_temp>.
*          APPEND <gfs_row_temp> TO <gfs_tab> .
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        lv_non_srep = abap_true.
      ENDIF. " IF sy-subrc IS INITIAL
    ELSE. " ELSE -> IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED
      lv_non_srep = abap_true.
    ENDIF. " IF <gfs_desc> IS ASSIGNED AND <gfs_fld> IS ASSIGNED AND <gfs_rdesc> IS ASSIGNED

    IF lv_non_srep = abap_true.
      UNASSIGN <gfs_fld>.
      ASSIGN COMPONENT c_kunnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
      IF <gfs_fld> IS NOT ASSIGNED .
        UNASSIGN <gfs_fld>.
        ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_fld>.

      ENDIF. " IF <gfs_fld> IS NOT ASSIGNED
      IF <gfs_fld> IS ASSIGNED.
        CLEAR : lwa_kna1.
        READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <gfs_fld>.
        IF sy-subrc IS INITIAL.
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = lwa_kna1-kukla.
          ENDIF. " IF <gfs_desc> IS ASSIGNED

        ENDIF. " IF sy-subrc IS INITIAL


        READ TABLE li_knvv ASSIGNING <lfs_knvv> WITH KEY kunnr = <gfs_fld>
                                                         BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          UNASSIGN <gfs_desc>.
          ASSIGN COMPONENT c_zzkvgr1 OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED .
            <gfs_desc> = <lfs_knvv>-kvgr1.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED


          ASSIGN COMPONENT c_zzkvgr2 OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = <lfs_knvv>-kvgr2.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED

          ASSIGN COMPONENT c_kdgrp OF STRUCTURE <gfs_row> TO <gfs_desc>.
          IF <gfs_desc> IS ASSIGNED.
            <gfs_desc> = <lfs_knvv>-kdgrp.
            UNASSIGN <gfs_desc>.
          ENDIF. " IF <gfs_desc> IS ASSIGNED
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF <gfs_fld> IS ASSIGNED
    ENDIF. " IF lv_non_srep = abap_true
*********


*---> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'VKORG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED.
      UNASSIGN <gfs_desc>.
      ASSIGN COMPONENT 'VKORG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Name
          FROM  tvkot       " Organizational Unit: Sales Organizations: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   vkorg = <gfs_fld>.
        UNASSIGN <gfs_desc>.
        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVKOT'.
          wa_fdtl-fieldname = 'VKORG_DESC'.
          wa_fdtl-rollname = 'VTXTK'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR : wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED.
      UNASSIGN <gfs_desc>.
      ASSIGN COMPONENT 'VTWEG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Name
          FROM tvtwt        " Organizational Unit: Distribution Channels: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND vtweg = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVTWT'.
          wa_fdtl-fieldname = 'VTWEG_DESC'.
          wa_fdtl-rollname = 'VTXTK'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED.
      ASSIGN COMPONENT 'KUNNR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE name1 " Name 1
          FROM kna1         " General Data in Customer Master
          INTO <gfs_desc>
          WHERE kunnr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'KNA1'.
          wa_fdtl-fieldname = 'KUNNR_DESC'.
          wa_fdtl-rollname = 'NAME1_GP'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED.
      ASSIGN COMPONENT 'KUNAG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE name1 " Name 1
          FROM kna1         " General Data in Customer Master
          INTO <gfs_desc>
          WHERE kunnr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'KNA1'.
          wa_fdtl-fieldname = 'KUNAG_DESC'.
          wa_fdtl-rollname = 'NAME1_GP'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KUNWE' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED.
      ASSIGN COMPONENT 'KUNWE_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE name1 " Name 1
          FROM kna1         " General Data in Customer Master
          INTO <gfs_desc>
          WHERE kunnr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'KNA1'.
          wa_fdtl-fieldname = 'KUNWE_DESC'.
          wa_fdtl-rollname = 'NAME1_GP'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KDGRP' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'KDGRP_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE ktext " Name
          FROM t151t        " Customers: Customer groups: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kdgrp = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'T151T'.
          wa_fdtl-fieldname = 'KDGRP_DESC'.
          wa_fdtl-rollname = 'VTXTK'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKATR7' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKATR7_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tvk7t        " Attribute 7 texts (customer master)
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   katr7 = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVK7T'.
          wa_fdtl-fieldname = 'ZZKATR7_DESC'.
          wa_fdtl-rollname = 'VTEXT'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF . " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'BRSCH' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'BRSCH_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE brtxt " Description of the industry key
        FROM t016t          " Industry Names
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND brsch = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'T016T'.
          wa_fdtl-fieldname = 'BRSCH_DESC'.
          wa_fdtl-rollname = 'TEXT1_016T'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZMVGR4' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZMVGR4_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvm4t        " Material pricing group 4: Description
          INTO <gfs_desc>
          WHERE spras  = sy-langu
          AND   mvgr4 = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVM4T'.
          wa_fdtl-fieldname = 'ZZMVGR4_DESC'.
          wa_fdtl-rollname = 'BEZEI40'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKDKG1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKDKG1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kdkgr = <gfs_fld>.
        UNASSIGN <gfs_desc>.


        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVKGGT'.
          wa_fdtl-fieldname = 'ZZKDG1_DESC'.
          wa_fdtl-rollname = 'VTEXT'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KONDM' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'KONDM_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM t178t        " Conditions: Groups for Materials: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND  kondm = <gfs_fld>.
        UNASSIGN <gfs_desc>.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    IF lv_count  = 1.   " INC0524176-01
      wa_fdtl-tabname =  'T178T'.
      wa_fdtl-fieldname = 'KONDM_DESC'.
      wa_fdtl-rollname = 'VTEXT'.
      APPEND wa_fdtl TO i_fdtl.
      CLEAR: wa_fdtl.
    ENDIF.
    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKDKG2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKDKG2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kdkgr = <gfs_fld>.
        UNASSIGN <gfs_desc>.


        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVKGGT'.
          wa_fdtl-fieldname = 'ZZKDG2_DESC'.
          wa_fdtl-rollname = 'VTEXT'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKDKG3' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKDKG3_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kdkgr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01

          wa_fdtl-tabname =  'TVKGGT'.
          wa_fdtl-fieldname = 'ZZKDG3_DESC'.
          wa_fdtl-rollname = 'VTEXT'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'MFRGR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'MFRGR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tmfgt        " Material freight groups: Descriptions
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   mfrgr = <gfs_fld>.
        UNASSIGN <gfs_desc>.


        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TMFGT'.
          wa_fdtl-fieldname = 'MFRGR_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKUKLA' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKUKLA_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tkukt        " Customers: Customer classification: Texts
          INTO  <gfs_desc>
          WHERE spras = sy-langu
          AND   kukla = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TKUKT'.
          wa_fdtl-fieldname = 'ZZKUKLA_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKVGR1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .

      ASSIGN COMPONENT 'ZZKVGR1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvv1t        " Customer group 1: Description
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kvgr1 = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVV1T'.
          wa_fdtl-fieldname = 'ZZKVGR1_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED



    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKVGR2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKVGR2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvv2t        " Customer group 2: Description
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kvgr2 = <gfs_fld>.
        UNASSIGN <gfs_desc>.


        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVV2T'.
          wa_fdtl-fieldname = 'ZZKVGR2_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT c_kukla_desc OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM tkukt        " Customer group 2: Description
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND  kukla  = <gfs_fld>.
        UNASSIGN <gfs_desc>.


        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TKUKT'.
          wa_fdtl-fieldname = c_kukla_desc.
          wa_fdtl-rollname = c_kukla_desc_d.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED
*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZKVGR5' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZKVGR5_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvv5t        " Customer group 5: Description
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   kvgr5 = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01

          wa_fdtl-tabname =  'TVV5T'.
          wa_fdtl-fieldname = 'ZZKVGR5_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED


    UNASSIGN <gfs_fld>.
*&-- Begin of change for HANAtization on OTC_RDD_0028 by U106341 on 03_mar-2020
   ASSIGN COMPONENT 'LAND1' OF STRUCTURE <gfs_row> TO FIELD-SYMBOL(<lfs_land1>).
    IF <lfs_land1> IS ASSIGNED .
*&-- End of change for HANAtization on OTC_RDD_0028 by U106341 on 03_mar-2020



    ASSIGN COMPONENT 'REGIO' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'REGIO_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM t005u        " Taxes: Region Key: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   bland = <gfs_fld>
*&-- Begin of Delete for HANAtization on OTC_RDD_0028 by U106341 on 03_mar-2020
          AND   land1 = <lfs_land1>.
*&-- End of Delete for HANAtization on OTC_RDD_0028 by U106341 on 03_mar-2020
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'T005U'.
          wa_fdtl-fieldname = 'REGIO_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED
    ENDIF. " IF <lfs_land1> is assigned



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'WERKS_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE name1 " Name
        FROM t001w          " Plants/Branches
        INTO <gfs_desc>
          WHERE werks = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'T001W'.
          wa_fdtl-fieldname = 'WERKS_DESC'.
          wa_fdtl-rollname = 'NAME1'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'AUART' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'AUART_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvakt        " Sales Document Types: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   auart = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVAKT'.
          wa_fdtl-fieldname = 'AUART_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'AUGRU' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'AUGRU_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tvaut        " Sales Documents: Order Reasons: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   augru = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TVAUT'.
          wa_fdtl-fieldname = 'AUGRU_DESC'.
          wa_fdtl-rollname = 'BEZEI40'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.
        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'ZZBSARK' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'ZZBSARK_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM t176t        " Sales Documents: Customer Order Types: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   bsark = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'T176T'.
          wa_fdtl-fieldname = 'ZZBSARK_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED



    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'INCO1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'INCO1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE bezei " Description
          FROM tinct        " Customers: Incoterms: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   inco1 = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TINCT'.
          wa_fdtl-fieldname = 'INCO1_DESC'.
          wa_fdtl-rollname = 'BEZEI30'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'TRAGR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'TRAGR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE vtext " Description
          FROM ttgrt        " Shipping Scheduling: Transportation Groups: Texts
          INTO <gfs_desc>
          WHERE spras = sy-langu
          AND   tragr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'TTGRT'.
          wa_fdtl-fieldname = 'TRAGR_DESC'.
          wa_fdtl-rollname = 'BEZEI20'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.

      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED

    UNASSIGN <gfs_fld>.
    ASSIGN COMPONENT 'KUNN2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
    IF <gfs_fld> IS ASSIGNED .
      ASSIGN COMPONENT 'KUNN2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
      IF <gfs_desc> IS ASSIGNED .
        SELECT SINGLE name1 " Name 1
          FROM kna1         " General Data in Customer Master
          INTO <gfs_desc>
          WHERE kunnr = <gfs_fld>.
        UNASSIGN <gfs_desc>.

        IF lv_count  = 1.   " INC0524176-01
          wa_fdtl-tabname =  'KNA1'.
          wa_fdtl-fieldname = 'KUNN2'.
          wa_fdtl-rollname = 'KUNNR_V'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

          wa_fdtl-tabname =  'KNA1'.
          wa_fdtl-fieldname = 'KUNN2_DESC'.
          wa_fdtl-rollname = 'NAME1_GP'.
          APPEND wa_fdtl TO i_fdtl.
          CLEAR: wa_fdtl.

        ENDIF.
      ENDIF. " IF <gfs_desc> IS ASSIGNED
    ENDIF. " IF <gfs_fld> IS ASSIGNED
    MOVE-CORRESPONDING <gfs_row> TO <gfs_row_temp>.
    APPEND <gfs_row_temp> TO <gfs_tab> .
  ENDLOOP. " LOOP AT <gfs_tab_temp1> ASSIGNING <gfs_row>

  CLEAR lv_count.   " INC0524176-01
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN

  UNASSIGN <gfs_tab_temp1>.

  IF <gfs_tab> IS INITIAL.
    MESSAGE e134 . "DISPLAY LIKE text-052. " Data Not Found !!
    LEAVE LIST-PROCESSING.
  ENDIF. " IF <gfs_tab> IS INITIAL


*<-- End of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.

*** Fetch Data for Scales.

*&-- Begin of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
*  LOOP AT  <gfs_tab> ASSIGNING <gfs_row>.
*    ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF sy-subrc EQ 0.
*      CLEAR : lwa_konh.
*      MOVE <gfs_fld> TO lwa_konh-knumh.
*      APPEND lwa_konh TO li_konh.
*    ENDIF. " IF sy-subrc EQ 0
*
*
*
*
*** Begin of Change for Defect#913 by SAGARWA1
****  Fetch Material to get Material Description.
*    CLEAR lwa_mara.
*    ASSIGN COMPONENT c_matnr OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF sy-subrc EQ 0.
*      MOVE <gfs_fld> TO lwa_mara-matnr.
*      APPEND lwa_mara TO li_mara.
*    ENDIF. " IF sy-subrc EQ 0
*** End   of Change for Defect#913 by SAGARWA1

*
**---> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'VKORG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED.
*      UNASSIGN <gfs_desc>.
*      ASSIGN COMPONENT 'VKORG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Name
*          FROM  tvkot       " Organizational Unit: Sales Organizations: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   vkorg = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*        wa_fdtl-tabname =  'TVKOT'.
*        wa_fdtl-fieldname = 'VKORG_DESC'.
*        wa_fdtl-rollname = 'VTXTK'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR : wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED.
*      UNASSIGN <gfs_desc>.
*      ASSIGN COMPONENT 'VTWEG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Name
*          FROM tvtwt        " Organizational Unit: Distribution Channels: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND vtweg = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVTWT'.
*        wa_fdtl-fieldname = 'VTWEG_DESC'.
*        wa_fdtl-rollname = 'VTXTK'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED.
*      ASSIGN COMPONENT 'KUNNR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE name1 " Name 1
*          FROM kna1         " General Data in Customer Master
*          INTO <gfs_desc>
*          WHERE kunnr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'KNA1'.
*        wa_fdtl-fieldname = 'KUNNR_DESC'.
*        wa_fdtl-rollname = 'NAME1_GP'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KUNAG' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED.
*      ASSIGN COMPONENT 'KUNAG_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE name1 " Name 1
*          FROM kna1         " General Data in Customer Master
*          INTO <gfs_desc>
*          WHERE kunnr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'KNA1'.
*        wa_fdtl-fieldname = 'KUNAG_DESC'.
*        wa_fdtl-rollname = 'NAME1_GP'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KUNWE' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED.
*      ASSIGN COMPONENT 'KUNWE_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE name1 " Name 1
*          FROM kna1         " General Data in Customer Master
*          INTO <gfs_desc>
*          WHERE kunnr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'KNA1'.
*        wa_fdtl-fieldname = 'KUNWE_DESC'.
*        wa_fdtl-rollname = 'NAME1_GP'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KDGRP' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'KDGRP_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE ktext " Name
*          FROM t151t        " Customers: Customer groups: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kdgrp = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'T151T'.
*        wa_fdtl-fieldname = 'KDGRP_DESC'.
*        wa_fdtl-rollname = 'VTXTK'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKATR7' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKATR7_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tvk7t        " Attribute 7 texts (customer master)
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   katr7 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVK7T'.
*        wa_fdtl-fieldname = 'ZZKATR7_DESC'.
*        wa_fdtl-rollname = 'VTEXT'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF . " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'BRSCH' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'BRSCH_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE brtxt " Description of the industry key
*        FROM t016t          " Industry Names
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND brsch = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'T016T'.
*        wa_fdtl-fieldname = 'BRSCH_DESC'.
*        wa_fdtl-rollname = 'TEXT1_016T'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZMVGR4' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZMVGR4_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvm4t        " Material pricing group 4: Description
*          INTO <gfs_desc>
*          WHERE spras  = sy-langu
*          AND   mvgr4 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVM4T'.
*        wa_fdtl-fieldname = 'ZZMVGR4_DESC'.
*        wa_fdtl-rollname = 'BEZEI40'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKDKG1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKDKG1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kdkgr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TVKGGT'.
*        wa_fdtl-fieldname = 'ZZKDG1_DESC'.
*        wa_fdtl-rollname = 'VTEXT'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KONDM' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'KONDM_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM t178t        " Conditions: Groups for Materials: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND  kondm = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    wa_fdtl-tabname =  'T178T'.
*    wa_fdtl-fieldname = 'KONDM_DESC'.
*    wa_fdtl-rollname = 'VTEXT'.
*    APPEND wa_fdtl TO i_fdtl.
*    CLEAR: wa_fdtl.
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKDKG2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKDKG2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kdkgr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TVKGGT'.
*        wa_fdtl-fieldname = 'ZZKDG2_DESC'.
*        wa_fdtl-rollname = 'VTEXT'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKDKG3' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKDKG3_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tvkggt       " Texts for Customer Condition Groups (Customer Master)
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kdkgr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TVKGGT'.
*        wa_fdtl-fieldname = 'ZZKDG3_DESC'.
*        wa_fdtl-rollname = 'VTEXT'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'MFRGR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'MFRGR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tmfgt        " Material freight groups: Descriptions
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   mfrgr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TMFGT'.
*        wa_fdtl-fieldname = 'MFRGR_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKUKLA' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKUKLA_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tkukt        " Customers: Customer classification: Texts
*          INTO  <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kukla = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TKUKT'.
*        wa_fdtl-fieldname = 'ZZKUKLA_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKVGR1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*
*      ASSIGN COMPONENT 'ZZKVGR1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvv1t        " Customer group 1: Description
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kvgr1 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVV1T'.
*        wa_fdtl-fieldname = 'ZZKVGR1_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*
*
*
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKVGR2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKVGR2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvv2t        " Customer group 2: Description
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kvgr2 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TVV2T'.
*        wa_fdtl-fieldname = 'ZZKVGR2_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
**--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT c_kukla OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT c_kukla_desc OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM tkukt        " Customer group 2: Description
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND  kukla  = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TKUKT'.
*        wa_fdtl-fieldname = c_kukla_desc.
*        wa_fdtl-rollname = c_kukla_desc_d.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
**<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZKVGR5' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZKVGR5_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvv5t        " Customer group 5: Description
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   kvgr5 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*
*        wa_fdtl-tabname =  'TVV5T'.
*        wa_fdtl-fieldname = 'ZZKVGR5_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'REGIO' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'REGIO_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM t005u        " Taxes: Region Key: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   bland = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'T005U'.
*        wa_fdtl-fieldname = 'REGIO_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'WERKS_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE name1 " Name
*        FROM t001w          " Plants/Branches
*        INTO <gfs_desc>
*          WHERE werks = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'T001W'.
*        wa_fdtl-fieldname = 'WERKS_DESC'.
*        wa_fdtl-rollname = 'NAME1'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'AUART' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'AUART_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvakt        " Sales Document Types: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   auart = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVAKT'.
*        wa_fdtl-fieldname = 'AUART_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'AUGRU' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'AUGRU_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tvaut        " Sales Documents: Order Reasons: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   augru = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TVAUT'.
*        wa_fdtl-fieldname = 'AUGRU_DESC'.
*        wa_fdtl-rollname = 'BEZEI40'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'ZZBSARK' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'ZZBSARK_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM t176t        " Sales Documents: Customer Order Types: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   bsark = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'T176T'.
*        wa_fdtl-fieldname = 'ZZBSARK_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'INCO1' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'INCO1_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE bezei " Description
*          FROM tinct        " Customers: Incoterms: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   inco1 = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*        wa_fdtl-tabname =  'TINCT'.
*        wa_fdtl-fieldname = 'INCO1_DESC'.
*        wa_fdtl-rollname = 'BEZEI30'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'TRAGR' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'TRAGR_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE vtext " Description
*          FROM ttgrt        " Shipping Scheduling: Transportation Groups: Texts
*          INTO <gfs_desc>
*          WHERE spras = sy-langu
*          AND   tragr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*
*        wa_fdtl-tabname =  'TTGRT'.
*        wa_fdtl-fieldname = 'TRAGR_DESC'.
*        wa_fdtl-rollname = 'BEZEI20'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
*    UNASSIGN <gfs_fld>.
*    ASSIGN COMPONENT 'KUNN2' OF STRUCTURE <gfs_row> TO <gfs_fld>.
*    IF <gfs_fld> IS ASSIGNED .
*      ASSIGN COMPONENT 'KUNN2_DESC' OF STRUCTURE <gfs_row> TO <gfs_desc>.
*      IF <gfs_desc> IS ASSIGNED .
*        SELECT SINGLE name1 " Name 1
*          FROM kna1         " General Data in Customer Master
*          INTO <gfs_desc>
*          WHERE kunnr = <gfs_fld>.
*        UNASSIGN <gfs_desc>.
*
*        wa_fdtl-tabname =  'KNA1'.
*        wa_fdtl-fieldname = 'KUNN2'.
*        wa_fdtl-rollname = 'KUNNR_V'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*        wa_fdtl-tabname =  'KNA1'.
*        wa_fdtl-fieldname = 'KUNN2_DESC'.
*        wa_fdtl-rollname = 'NAME1_GP'.
*        APPEND wa_fdtl TO i_fdtl.
*        CLEAR: wa_fdtl.
*
*      ENDIF. " IF <gfs_desc> IS ASSIGNED
*    ENDIF. " IF <gfs_fld> IS ASSIGNED
*
**<--- End of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.
*  ENDLOOP. " LOOP AT <gfs_tab> ASSIGNING <gfs_row>
*&-- End of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019


*---> Begin of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
  wa_fdtl-tabname =  'MAKTX'.
  wa_fdtl-fieldname = 'MATNR_DESC'.
  wa_fdtl-rollname = 'MAKTX'.
  APPEND wa_fdtl TO i_fdtl.
  CLEAR: wa_fdtl.
*<--- End of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.





* ---> Begin of Delete for D3 COE Defect 2479 by DMOIRAN
*Below code has been commented out and moved up in this subroutine
*as there are multiple select from table T685A.

****--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH
**
*    SELECT SINGLE kappl " Application
*    kschl               " Condition type
*    txtgr               " Text determination procedure
*    tdid                " Text ID for text edit control
*    FROM t685a          " Conditions: Types: Additional Price Element Data
*      INTO lwa_t685a
*      WHERE kappl = p_kappl
*      AND   kschl = p_kschl.
**
****<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
*
* <--- End    of Delete for D3 COE Defect 2479 by DMOIRAN

*&-- Begin of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
**    SORT li_konp BY knumh.
******  Update KONP details to the final internal table .
**    LOOP AT <gfs_tab> ASSIGNING <gfs_row>.

**      ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_fld>.
**
**      ASSIGN COMPONENT c_counter OF STRUCTURE <gfs_row> TO <gfs_desc>.
**      MOVE '0' TO <gfs_desc>.
**      UNASSIGN <gfs_desc>.
**
**
**      ASSIGN COMPONENT c_kotabnr OF STRUCTURE <gfs_row> TO <gfs_desc>.
**      MOVE p_tab TO <gfs_desc>.
**      UNASSIGN <gfs_desc>.
**
**
**      READ TABLE li_konp ASSIGNING <lfs_konp> WITH KEY knumh = <gfs_fld> BINARY SEARCH.
**      IF sy-subrc IS INITIAL.
**        ASSIGN COMPONENT c_loevm_ko OF STRUCTURE <gfs_row> TO <gfs_desc>.
**        MOVE <lfs_konp>-loevm_ko TO <gfs_desc>.
**        UNASSIGN <gfs_desc>.
**        ASSIGN COMPONENT c_kmein OF STRUCTURE <gfs_row> TO <gfs_desc>.
**        MOVE <lfs_konp>-kmein TO <gfs_desc>.
**        UNASSIGN <gfs_desc>.
**        ASSIGN COMPONENT c_kpein OF STRUCTURE <gfs_row> TO <gfs_desc>.
**        MOVE <lfs_konp>-kpein TO <gfs_desc>.
**        UNASSIGN <gfs_desc>.
***        ** Begin of Change for Defect#913 by SAGARWA1
*** Add Currency value
**        ASSIGN COMPONENT c_konwa OF STRUCTURE <gfs_row> TO <gfs_desc>.
**        MOVE <lfs_konp>-konwa TO <gfs_desc>.
**        UNASSIGN <gfs_desc>.
**** End   of Change for Defect#913 by SAGARWA1
**        ASSIGN COMPONENT c_kbetr OF STRUCTURE <gfs_row> TO <gfs_desc>.
**        IF <lfs_konp>-konwa = '%'.
**          COMPUTE <lfs_konp>-kbetr = <lfs_konp>-kbetr / 10.
**        ENDIF. " IF <lfs_konp>-konwa = '%'
***--> Begin of insert for D2_OTC_RDD_0028 / Defect 1264 by VCHOUDH.
*** Check if the pricing condition type is of discount type
*** T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
**        IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0.00'.
**          <lfs_konp>-kbetr = <lfs_konp>-kbetr * -1.
**          MOVE <lfs_konp>-kbetr TO <gfs_desc>.
**        ELSE. " ELSE -> IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
***<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
**          MOVE <lfs_konp>-kbetr TO <gfs_desc>.
***--> Begin of insert for D2_OTC_RDD_0028 / Defect 1264 by VCHOUDH.
**        ENDIF. " IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
***<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
**        UNASSIGN <gfs_desc>.
**
**        ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_desc>.
***--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
**
**        CLEAR lv_name.
**        CONCATENATE <gfs_desc> <lfs_konp>-kopos INTO lv_name.
**
**        lv_obj = lc_konp.
**        CALL FUNCTION 'READ_TEXT'
**          EXPORTING
***           CLIENT                  = SY-MANDT
**            id                      = lwa_t685a-tdid
**            language                = sy-langu
**            name                    = lv_name
**            object                  = lv_obj
**          TABLES
**            lines                   = li_tline
**          EXCEPTIONS
**            id                      = 1
**            language                = 2
**            name                    = 3
**            not_found               = 4
**            object                  = 5
**            reference_check         = 6
**            wrong_access_to_archive = 7
**            OTHERS                  = 8.
**        IF sy-subrc <> 0.
**          UNASSIGN <gfs_desc>.
**          ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
**          IF <gfs_desc> IS ASSIGNED .
**            <gfs_desc> = 'N'.
**          ENDIF. " IF <gfs_desc> IS ASSIGNED
**        ELSE. " ELSE -> IF sy-subrc <> 0
**          UNASSIGN <gfs_desc>.
**          READ TABLE li_tline INTO lwa_tline INDEX 1.
**          IF sy-subrc IS INITIAL.
**            ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
**            IF <gfs_desc> IS ASSIGNED .
**              <gfs_desc> = 'Y'.
**            ENDIF. " IF <gfs_desc> IS ASSIGNED
**            UNASSIGN <gfs_desc>.
**            ASSIGN COMPONENT c_record_txt OF STRUCTURE <gfs_row> TO <gfs_desc>.
**            IF <gfs_desc> IS ASSIGNED .
**              <gfs_desc> = lwa_tline-tdline.
**              UNASSIGN <gfs_desc>.
**            ENDIF. " IF <gfs_desc> IS ASSIGNED
**          ELSE. " ELSE -> IF sy-subrc IS INITIAL
**
**            ASSIGN COMPONENT c_record OF STRUCTURE <gfs_row> TO <gfs_desc>.
**            IF <gfs_desc> IS ASSIGNED .
**              <gfs_desc> = 'N'.
**            ENDIF. " IF <gfs_desc> IS ASSIGNED
**
**          ENDIF. " IF sy-subrc IS INITIAL
**
**        ENDIF. " IF sy-subrc <> 0
***<-- End of Addition for D2_OTC_RDD_00028/Defect 1191 by VCHOUDH.
**
**
**
**
**
**
**      ENDIF. " IF sy-subrc IS INITIAL
**    ENDLOOP. " LOOP AT <gfs_tab> ASSIGNING <gfs_row>
*&-- End of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019


* Begin of change for Defect # 9379 by U105993
  IF li_konp IS NOT INITIAL.
*  End of change for Defect # 9379 by U105993
    IF lv_kzbzg = lc_value_b. "++D3 COE Defect 2479
** Begin of Change for Defect#913 by SAGARWA1
      SELECT knumh " Condition record number
             kopos " Sequential number of the condition
             klfn1 " Current number of the line scale
             kstbw " Scale value
             kbetr " Rate (condition amount or percentage)
        FROM konw  " Conditions (1-Dimensional Value Scale)
        INTO TABLE li_konw
        FOR ALL ENTRIES IN li_konp
        WHERE knumh = li_konp-knumh.
      IF sy-subrc = 0.
        SORT li_konw BY knumh kopos klfn1.
      ENDIF. " IF sy-subrc = 0
** End   of Change for Defect#913 by SAGARWA1


* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
    ELSEIF lv_kzbzg = lc_qty_c.
* Get the scale data for Quantity scale pricing condition type
      SELECT knumh " Condition record number
             kopos " Sequential number of the condition
             klfn1 " Current number of the line scale
             kstbm " Condition scale quantity
             kbetr " Rate (condition amount or percentage)
        FROM konm  " Conditions (1-Dimensional Quantity Scale)
        INTO TABLE li_konm
        FOR ALL ENTRIES IN li_konp
        WHERE knumh = li_konp-knumh.
      IF sy-subrc = 0.
        SORT li_konm BY knumh kopos klfn1.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lv_kzbzg = lc_value_b
*   Begin of change for Defect # 9379 by U105993
  ENDIF. " IF li_konp IS NOT INITIAL.
*   End of change for Defect # 9379 by U105993
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN

  UNASSIGN <lfs_konp>.
  LOOP AT li_konp ASSIGNING <lfs_konp> WHERE  kzbzg <> ''.
    lwa_scale-knumh  =  <lfs_konp>-knumh.
    lwa_scale-kstbm  =  <lfs_konp>-kstbm.
*      lwa_scale-konms  =  <lfs_konp>-kwaeh.   "--D3 COE Defect 2479
    lwa_scale-konms  =  <lfs_konp>-kmein. "++D3 COE Defect 2479


*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
* *Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
    IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0.00'.
      lwa_scale-kbetr = <lfs_konp>-kbetr * -1.
    ELSE. " ELSE -> IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
      lwa_scale-kbetr  =  <lfs_konp>-kbetr.
*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
    ENDIF. " IF lv_knega = abap_true AND <lfs_konp>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264  by VCHOUDH.
    lwa_scale-konws  =  <lfs_konp>-kwaeh.
    lwa_scale-kpein  =  <lfs_konp>-kpein.
    lwa_scale-kmein  =  <lfs_konp>-kmein.
    lwa_scale-konwa  = <lfs_konp>-konwa.
** Begin of Change for Defect#913 by SAGARWA1
    UNASSIGN <lfs_konw>.

    IF lv_kzbzg = lc_value_b. "++D3 COE Defect 2479
      LOOP AT li_konw ASSIGNING <lfs_konw> WHERE knumh = <lfs_konp>-knumh.
        lwa_scale-kstbm = <lfs_konw>-kstbw.

*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
* *Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
        IF lv_knega = abap_true AND <lfs_konw>-kbetr < '0.00'.
          lwa_scale-kbetr = <lfs_konw>-kbetr * -1.
        ELSE. " ELSE -> IF lv_knega = abap_true AND <lfs_konw>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
          lwa_scale-kbetr = <lfs_konw>-kbetr.
*--> Begin of Insert for D2_OTC_RDD_0028/Defect 1264 by VCHOUDH.
        ENDIF. " IF lv_knega = abap_true AND <lfs_konw>-kbetr < '0 00'
*<-- End of Insert for D2_OTC_RDD_0028/Defect 1264  by VCHOUDH.
        APPEND lwa_scale TO li_scale.
      ENDLOOP. " LOOP AT li_konw ASSIGNING <lfs_konw> WHERE knumh = <lfs_konp>-knumh
** End   of Change for Defect#913 by SAGARWA1
** Begin of Delete for Defect#913 by SAGARWA1
*      APPEND lwa_scale TO li_scale.
** End   of Delete for Defect#913 by SAGARWA1

* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
    ELSEIF lv_kzbzg = lc_qty_c.
* Add the quantity scale data
      LOOP AT li_konm ASSIGNING <lfs_konm> WHERE knumh = <lfs_konp>-knumh.
        lwa_scale-kstbm = <lfs_konm>-kstbm.
* *Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so,then remove the -ve sign in kbetr.
        IF lv_knega = abap_true AND <lfs_konm>-kbetr < '0.00'.
          lwa_scale-kbetr = <lfs_konm>-kbetr * -1.
        ELSE. " ELSE -> IF lv_knega = abap_true AND <lfs_konm>-kbetr < '0 00'
          lwa_scale-kbetr = <lfs_konm>-kbetr.
        ENDIF. " IF lv_knega = abap_true AND <lfs_konm>-kbetr < '0 00'
        APPEND lwa_scale TO li_scale.
      ENDLOOP. " LOOP AT li_konm ASSIGNING <lfs_konm> WHERE knumh = <lfs_konp>-knumh
    ENDIF. " IF lv_kzbzg = lc_value_b
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN

    CLEAR lwa_scale.
  ENDLOOP. " LOOP AT li_konp ASSIGNING <lfs_konp> WHERE kzbzg <> ''

*************  Updating the final internal table.



  LOOP AT <gfs_tab> ASSIGNING <gfs_row>.

    MOVE-CORRESPONDING <gfs_row> TO <gfs_row_temp>.
    ASSIGN COMPONENT c_knumh OF STRUCTURE <gfs_row> TO <gfs_desc>.

    APPEND <gfs_row_temp> TO <gfs_tab_temp> .

    LOOP AT li_scale INTO lwa_scale WHERE knumh = <gfs_desc>.
      CLEAR <gfs_row_temp>.
      ASSIGN COMPONENT c_counter OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      MOVE '1' TO <gfs_fld>.
      UNASSIGN <gfs_fld>.

      ASSIGN COMPONENT c_kstbm OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      MOVE lwa_scale-kstbm TO <gfs_fld>.
      UNASSIGN <gfs_fld>.


      ASSIGN COMPONENT c_konwa OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      MOVE lwa_scale-konwa TO <gfs_fld>.
      UNASSIGN <gfs_desc>.

      ASSIGN COMPONENT c_kbetr1 OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED.
        UNASSIGN <gfs_rdesc>.
        ASSIGN COMPONENT c_konwa OF STRUCTURE <gfs_row> TO <gfs_rdesc>.
        IF <gfs_rdesc> = '%'.
          COMPUTE lwa_scale-kbetr = lwa_scale-kbetr / 10.
        ENDIF. " IF <gfs_rdesc> = '%'
        MOVE lwa_scale-kbetr TO <gfs_fld>.
        UNASSIGN <gfs_fld>.
        UNASSIGN <gfs_rdesc>.
      ENDIF. " IF <gfs_fld> IS ASSIGNED


      ASSIGN COMPONENT c_konws OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      MOVE lwa_scale-konws TO <gfs_fld>.
      UNASSIGN <gfs_fld>.

* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
* Added the UoM of scale.
      ASSIGN COMPONENT c_konms OF STRUCTURE <gfs_row_temp> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED.
        MOVE lwa_scale-konms TO <gfs_fld>.
        UNASSIGN <gfs_fld>.
      ENDIF. " IF <gfs_fld> IS ASSIGNED
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN

      APPEND <gfs_row_temp> TO <gfs_tab_temp> .

    ENDLOOP. " LOOP AT li_scale INTO lwa_scale WHERE knumh = <gfs_desc>

  ENDLOOP. " LOOP AT <gfs_tab> ASSIGNING <gfs_row>



IF i_fdtl IS NOT INITIAL.
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*&-- Delete duplicate entries before using for selection.
  li_fdtl[] = i_fdtl[].
  SORT li_fdtl BY rollname.
  DELETE ADJACENT DUPLICATES FROM li_fdtl COMPARING rollname.
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019

  SELECT rollname   " Data element (semantic domain)
         ddlanguage " Language Key
         as4local   " Activation Status of a Repository Object
         as4vers    " Version of the entry (not used)
         scrtext_l  " Long Field Label
    FROM dd04t      " R/3 DD: Data element texts
    INTO TABLE i_dd04t
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*      FOR ALL ENTRIES IN i_fdtl
*      WHERE rollname = i_fdtl-rollname
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
*&-- Begin of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
    FOR ALL ENTRIES IN li_fdtl
    WHERE rollname = li_fdtl-rollname
*&-- End of changes for D3_OTC_RDD_0028 Defect# 7919 by SMUKHER on 02-Jan-2019
    AND   ddlanguage = sy-langu.
    IF sy-subrc IS INITIAL.
      SORT i_dd04t BY rollname.
      LOOP AT i_fdtl ASSIGNING <gfs_fdtl>.
        READ TABLE i_dd04t ASSIGNING <gfs_dd04t> WITH KEY rollname = <gfs_fdtl>-rollname BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          <gfs_fdtl>-scrtext_l = <gfs_dd04t>-scrtext_l.
*          MODIFY i_fdtl FROM wa_fdtl TRANSPORTING scrtext_l.
        ENDIF. " IF sy-subrc IS INITIAL
** Begin of Change for Defect#913 by SAGARWA1
        IF <gfs_fdtl>-rollname = c_ztable.
          <gfs_fdtl>-scrtext_l = 'Table Indicator'(011).

        ENDIF. " IF <gfs_fdtl>-rollname = c_ztable
** End   of Change for Defect#913 by SAGARWA1
*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
        IF <gfs_fdtl>-rollname = c_zrecord.
          <gfs_fdtl>-scrtext_l = 'Condition Text Indi'.

        ENDIF. " IF <gfs_fdtl>-rollname = c_zrecord
        IF <gfs_fdtl>-rollname = c_zrecord_txt.
          <gfs_fdtl>-scrtext_l = 'Condition Record Text'.

        ENDIF. " IF <gfs_fdtl>-rollname = c_zrecord_txt

*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.
      ENDLOOP. " LOOP AT i_fdtl ASSIGNING <gfs_fdtl>
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF i_fdtl IS NOT INITIAL
*********Create char internal table.

  PERFORM f_create_char_table.
**************************************



  IF p_chk2 = abap_true.
    IF p_pres = abap_true.
      PERFORM f_save_presentation. "   Save the File on presentation server
    ELSEIF p_app = abap_true.
      PERFORM f_save_appl. "  Save file on Application server
    ELSEIF p_email = abap_true.
      PERFORM f_send_mail. "   Send the file as attachment in mail.
    ENDIF. " IF p_pres = abap_true
  ENDIF. " IF p_chk2 = abap_true
ENDFORM. " FETCH_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM f_display_data .

*  Using ALV factory method to display the final output.
  CLEAR : gv_table_alv.
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = gv_table_alv
        CHANGING
          t_table      = <gfs_tab_temp>.
    CATCH cx_salv_msg .
  ENDTRY.

  IF gv_table_alv IS NOT INITIAL.

*&-- Begin of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
** Activate standard Functions of ALV **
*    gv_functions_alv = gv_table_alv->get_functions( ).    " By RNATHAK
*    gv_functions_alv->set_all( if_salv_c_bool_sap=>true ).  " By RNATHAK
** Activate Standard Layout Options **
*    MOVE sy-repid TO gv_layout_key_alv-report.    " By RNATHAK
*    gv_layout_alv = gv_table_alv->get_layout( ).                               " By RNATHAK
*    gv_layout_alv->set_key( gv_layout_key_alv ).                                  " By RNATHAK
*    gv_layout_alv->set_save_restriction( if_salv_c_layout=>restrict_none ).   " By RNATHAK
*&-- End of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

** Column Settings **
    gv_columns_alv = gv_table_alv->get_columns( ).
    IF gv_columns_alv IS NOT INITIAL.
      PERFORM f_column_settings.
    ENDIF. " IF gv_columns_alv IS NOT INITIAL
*&-- Begin of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
*    gv_columns_alv->set_optimize( if_salv_c_bool_sap=>true ).       " By RNATHAK
*&-- End of delete for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

*--> Begin of Addition for D2_OTC_RDD_00028/Defect 1191 by VCHOUDH.
    gv_column_alv ?= gv_columns_alv->get_column( 'ZRECORD' ).
    gv_column_alv->set_long_text( 'Condition Txt Ind' ).


    gv_column_alv ?= gv_columns_alv->get_column( 'ZTEXT' ).
    gv_column_alv->set_long_text( 'Condition Text' ).


*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.

*--> Begin of Insert for <INCIDENT/SCTASK/DEFECT> <WRICEF ID> by <U106407> dated <DD/MM/YYYY>
*    PERFORM f_top_of_pages.
*****    FREE : gt_tab_temp1,
*****           gt_tab,
*****          <gfs_tab_temp1>.

    DATA(gd_repid) = sy-repid.
    gv_layout-colwidth_optimize = abap_true.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = gd_repid
        i_callback_top_of_page = 'F_TOP_OF_PAGES'  "see FORM
        it_fieldcat            = i_fieldcatalog[]
        is_layout              = gv_layout
      TABLES
        t_outtab               = <gfs_tab_temp>
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
*<-- End of Insert for <INCIDENT/SCTASK/DEFECT> <WRICEF ID> by <U106407> dated <DD/MM/YYYY>

*** Top of List **
*    PERFORM f_top_of_page CHANGING gv_content_alv.
*    gv_table_alv->set_top_of_list( gv_content_alv ).
*    CALL METHOD gv_table_alv->display.
  ENDIF. " IF gv_table_alv IS NOT INITIAL

ENDFORM. " DISPLAY_DATA


*&---------------------------------------------------------------------*
*&      Form  column_settings
*&---------------------------------------------------------------------*
* For Column settings for ALV Grid
*----------------------------------------------------------------------*
FORM f_column_settings.
  DATA: lv_col_name TYPE lvc_fname. "++D3 COE Defect 2479

  REFRESH : i_columns_alv.
  CLEAR : wa_columns_alv.
  i_columns_alv = gv_columns_alv->get( ).
  IF i_columns_alv[] IS NOT INITIAL.
    LOOP AT i_columns_alv INTO wa_columns_alv.
      TRY.
          gv_column_alv ?= gv_columns_alv->get_column( columnname = wa_columns_alv-columnname ).
        CATCH cx_salv_not_found .
      ENDTRY.
      IF gv_column_alv IS NOT INITIAL.
* ---> Begin of Insert for D3 COE Defect 2479 by DMOIRAN
* Add the currency field for amount (KBETR) field so that for currency like KRW (Korean Won)
* which doesn't have decimals will be diplay without decimal even though SAP stores it as
* 2 decimal values.

        lv_col_name = gv_column_alv->get_columnname( ).
        IF lv_col_name = c_kbetr.
          gv_column_alv->set_currency_column('KONWA').
        ENDIF. " IF lv_col_name = c_kbetr
* <--- End    of Insert for D3 COE Defect 2479 by DMOIRAN

        gv_domname_alv = gv_column_alv->get_ddic_domain( ).
**      Hide Client and condition number columns in ALV Grid
        IF gv_domname_alv EQ c_mandt OR gv_domname_alv EQ c_knumh.
          gv_column_alv->set_technical( if_salv_c_bool_sap=>true ).
        ENDIF. " IF gv_domname_alv EQ c_mandt OR gv_domname_alv EQ c_knumh
      ENDIF. " IF gv_column_alv IS NOT INITIAL

*--> Begin of Insert for <INCIDENT/SCTASK/DEFECT>
*<WRICEF ID> by <u106407> dated <DD/MM/YYYY>
      wa_fieldcatalog-fieldname   = lv_col_name.
      IF lv_col_name EQ 'ZRECORD'.
        wa_fieldcatalog-seltext_m = 'Condition Text'.
      ELSEIF lv_col_name EQ 'ZTEXT'.
        wa_fieldcatalog-seltext_m = 'Condition Text'.
      ELSE.
        wa_fieldcatalog-seltext_l = gv_column_alv->get_long_text( ).
      ENDIF.
*      wa_fieldcatalog-col
*      wa_fieldcatalog-outputlen = gv_column_alv->get_ddic_outputlen( ).
      IF lv_col_name EQ c_kbetr.
        wa_fieldcatalog-currency = 'KONWA'.
      ENDIF.

      APPEND wa_fieldcatalog TO i_fieldcatalog.
      CLEAR wa_fieldcatalog.
*<-- End of Insert <INCIDENT/SCTASK/DEFECT> <WRICEF
*ID> by <u106407> dated <DD/MM/YYYY>
    ENDLOOP. " LOOP AT i_columns_alv INTO wa_columns_alv
  ENDIF. " IF i_columns_alv[] IS NOT INITIAL

ENDFORM. "column_settings

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
* To setting Top of Page in ALV Grid
*----------------------------------------------------------------------*
*      --&gtLR_CONTENT text
*---------------------------------------------------------------------*
FORM f_top_of_page CHANGING lr_content TYPE REF TO cl_salv_form_element. " General Element in Design Object
  DATA : lr_grid  TYPE REF TO cl_salv_form_layout_grid, " Grid Element in Design Object
         lr_label TYPE REF TO cl_salv_form_label,      " Element of Type Label
         lr_head  TYPE string,
         lr_row   TYPE string.
  MOVE TEXT-058 TO lr_head.
  CONCATENATE TEXT-059 p_kschl INTO lr_row SEPARATED BY space. " Concatenate 'condition of type
  CREATE OBJECT lr_grid.


***  Top of page , for alv display.

  lr_grid->create_header_information(
                        row     = 1
                        column  = 1
                        text    = lr_head
                        tooltip = lr_head ).
  lr_grid->add_row( ).
  lr_label = lr_grid->create_label(
                        row         = 2
                        column      = 1
                        text        = lr_row
                        tooltip     = lr_row ).
  CONCATENATE TEXT-060 wa_tmc1t-gstru
              TEXT-061 wa_tmc1t-gstxt INTO lr_row SEPARATED BY space.
  lr_grid->add_row( ).
  lr_label = lr_grid->create_label(
                        row         = 3
                        column      = 1
                        text        = lr_row
                        tooltip     = lr_row ).
  lr_content = lr_grid.

ENDFORM. "top_of_page
*&---------------------------------------------------------------------*
*&      Form  SAVE_PRESENTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_presentation .
  DATA : lv_filename TYPE string.
  DATA : lv_limit TYPE i. " Limit of type Integers
  lv_filename = p_file.
  TRANSLATE lv_filename TO UPPER CASE.
*--> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.


  READ TABLE i_enh_status INTO wa_enh_status WITH KEY criteria = 'FILE_LIMIT'
                                                        active = abap_true.
  IF sy-subrc IS INITIAL.
    lv_limit = wa_enh_status-sel_low.
  ENDIF. " IF sy-subrc IS INITIAL

  IF gv_tab_counter > lv_limit.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = TEXT-111
        txt1  = TEXT-112
        txt2  = TEXT-113.

    REPLACE ALL OCCURRENCES OF '.XLS' IN lv_filename WITH '.TXT'.
    REPLACE ALL OCCURRENCES OF '.XLSX' IN lv_filename WITH '.TXT'.

  ENDIF. " IF gv_tab_counter > lv_limit


  IF p_txt = 'X'.
    REPLACE ALL OCCURRENCES OF '.XLS' IN lv_filename WITH '.TXT'.
    REPLACE ALL OCCURRENCES OF '.XLSX' IN lv_filename WITH '.TXT'.
  ENDIF. " IF p_txt = 'X'

*<-- End of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.




  IF lv_filename IS NOT INITIAL.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_filename
        write_field_separator = TEXT-057
      TABLES
        data_tab              = <gfs_tab_str>.

    IF p_chk1 NE 'X'.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF p_chk1 NE 'X'
  ENDIF. " IF lv_filename IS NOT INITIAL

ENDFORM. " SAVE_PRESENTATION
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_mail .

  DATA : lv_count TYPE i. " Count of type Integers
  " data declaration
  " variable declaration
  DATA : lv_lines_bin     TYPE i,           "no of lines for excel data
         lv_message_lines TYPE i,         "no of lines for body of mail
         lv_mailaddr      TYPE  ad_smtpadr. " storing email id
  CONSTANTS : lc_excel_name TYPE string VALUE 'Mass_Price_Upload',
              lc_ext        TYPE char4 VALUE '.XLS', " Ext of type CHAR4
              lc_ext1       TYPE char4 VALUE '.TXT'. " Ext1 of type CHAR4

  " class declaration
CLASS: cl_abap_char_utilities DEFINITION LOAD.

  " internal table declaration
  DATA: li_objpack     TYPE STANDARD TABLE OF  sopcklsti1,             " SAPoffice: Description of Imported Object Components
        li_message     TYPE STANDARD TABLE OF  solisti1 ,            " SAPoffice: Single List with Column Length 255
        li_reclist     TYPE STANDARD TABLE OF  somlreci1 ,             " SAPoffice: Structure of the API Recipient List
        li_objbin      TYPE STANDARD TABLE OF  solisti1 ,               " SAPoffice: Single List with Column Length 255
        lv_tab         TYPE c VALUE cl_abap_char_utilities=>horizontal_tab, " Tab of type Character
        lv_ret         TYPE c VALUE cl_abap_char_utilities=>cr_lf,          " Ret of type Character

        "work area declaration
        lwa_objbin     LIKE LINE OF li_objbin,
        lwa_message    LIKE LINE OF li_message,
        lwa_i_reclist  TYPE  somlreci1,                             " SAPoffice: Structure of the API Recipient List
        lwa_doc_chng   TYPE  sodocchgi1,                          " Data of an object which can be changed
*        lwa_i_orders   TYPE sfc_poco,                               " List structure for collective conversion of planned orders
        lwa_it_objpack TYPE  sopcklsti1. " SAPoffice: Description of Imported Object Components


  " populate the text for body of the mail
  CLEAR lwa_message.
  lwa_message-line = TEXT-004. " Please find above the excel attached
  APPEND lwa_message TO li_message.
  CLEAR lwa_message.


  DESCRIBE TABLE li_message LINES lv_message_lines. "no of lines for body of mail

  READ TABLE li_message INTO lwa_message INDEX lv_message_lines.
*  IF sy-subrc IS INITIAL.
*  ENDIF. " if sy-subrc is INITIAL
  "document information
  lwa_doc_chng-obj_name = TEXT-005. " Excel
  lwa_doc_chng-obj_descr = TEXT-006. "Excel For Unprocessed Orders
  lwa_doc_chng-sensitivty = TEXT-007. " F ->Functional object
  lwa_doc_chng-doc_size = ( lv_message_lines - 1 ) * 255 + strlen( lwa_message-line ). " calculating total size of doc



* describe the component table
  CLEAR : gv_val_index.
  DESCRIBE TABLE i_component LINES gv_val_index.



  LOOP AT <gfs_tab_str> ASSIGNING <gfs_row_str>.
    lv_count = 1.
    DO gv_val_index TIMES.
      ASSIGN COMPONENT lv_count OF STRUCTURE <gfs_row_str> TO <gfs_desc>.
      IF lwa_objbin IS INITIAL AND lv_count = 1.
        lwa_objbin = <gfs_desc>.

      ELSE. " ELSE -> IF lwa_objbin IS INITIAL AND lv_count = 1
        CONCATENATE lwa_objbin <gfs_desc> INTO lwa_objbin  SEPARATED BY lv_tab.
      ENDIF. " IF lwa_objbin IS INITIAL AND lv_count = 1
      UNASSIGN <gfs_desc>.
      lv_count = lv_count + 1.
    ENDDO.
    CONCATENATE lv_ret lwa_objbin INTO lwa_objbin.
    APPEND lwa_objbin TO li_objbin.
    CLEAR lwa_objbin.
  ENDLOOP. " LOOP AT <gfs_tab_str> ASSIGNING <gfs_row_str>

  DESCRIBE TABLE li_objbin LINES lv_lines_bin. " no of lines for excel data


  " pack the data as RAW
  CLEAR lwa_it_objpack-transf_bin. "Obj. to be transported not in binary form
  lwa_it_objpack-head_start = 1. "Start line of object header in transport packet
  lwa_it_objpack-head_num = 0. "Number of lines of an object header in object packet
  lwa_it_objpack-body_start = 1. "Start line of object contents in an object packet
  lwa_it_objpack-body_num = lv_message_lines. "Number of lines of the mail body
  lwa_it_objpack-doc_type = TEXT-008. "RAW
  APPEND lwa_it_objpack TO li_objpack.
  CLEAR lwa_it_objpack.

  " pack the data as excel
  lwa_it_objpack-transf_bin = TEXT-009. " X
  lwa_it_objpack-head_start = 1.
  lwa_it_objpack-head_num = 1.
  lwa_it_objpack-body_start = 1.
  lwa_it_objpack-body_num = lv_lines_bin. "no of lines of it_orders to give no of unprocessed orders
  lwa_it_objpack-doc_type = TEXT-012. " XLS ->  excel fomat
  lwa_it_objpack-obj_name = TEXT-013. " EXCEL ATTACHMENT

  " attachment name
  IF p_xls = 'X'.
    CONCATENATE lc_excel_name lc_ext INTO lwa_it_objpack-obj_descr.
  ELSEIF p_txt = 'X'.
    CONCATENATE lc_excel_name lc_ext1 INTO lwa_it_objpack-obj_descr.
  ENDIF. " IF p_xls = 'X'
  lwa_it_objpack-doc_size = lv_lines_bin * 255.
  APPEND lwa_it_objpack TO li_objpack.
  CLEAR lwa_it_objpack.
  " creating email id

  lv_mailaddr = p_mail.
* e-mail receivers.
  CLEAR lwa_i_reclist.
  lwa_i_reclist-receiver = lv_mailaddr.
  lwa_i_reclist-express =  'X'. "text-009.                      " X
  lwa_i_reclist-rec_type = 'U'. "text-013.                      " U ->  Internet address
  APPEND lwa_i_reclist TO li_reclist.
  CLEAR  lwa_i_reclist.


  " sending mail
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = lwa_doc_chng
      put_in_outbox              = TEXT-057
      commit_work                = TEXT-057
    TABLES
      packing_list               = li_objpack
      contents_bin               = li_objbin
      contents_txt               = li_message
      receivers                  = li_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e070 DISPLAY LIKE TEXT-051. " Email Not Sent
  ENDIF. " IF sy-subrc IS NOT INITIAL

  IF p_chk1 NE 'X'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_chk1 NE 'X'
ENDFORM. " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CHAR_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_char_table .
*********   Creating a structure similar to main internal table,
********     the differnce is here the fields must be of type string.
*******   After the string structure is created the data is copied .
  DATA : lv_str TYPE string.
  CONSTANTS : lc_string TYPE char10 VALUE 'STRING'. " String of type CHAR10
  DATA : lv_count TYPE i. " Count of type Integers
  DATA : lv_component_field TYPE string.
  DATA: lo_typedescr  TYPE REF TO cl_abap_typedescr. " Runtime Type Services
  SORT i_fdtl BY fieldname.
  CLEAR gv_tab_counter .

*---> Begin of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
* Local variables declaration
  DATA:
    li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table
* Field Symbol
  FIELD-SYMBOLS:
    <lfs_status> TYPE zdev_enh_status. " Enhancement Status
  CONSTANTS : lc_prefix TYPE z_criteria     VALUE 'PREFIX',           " Enh. Criteria
              lc_enh_no TYPE z_enhancement   VALUE 'D2_OTC_RDD_0028'. " Enhancement No.
******  Fetch the Prefix required fields from EMI .


* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

  DELETE li_status WHERE active = space.

  DELETE li_status WHERE criteria NE lc_prefix.

*<--- End of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.


**  creating the header line .
  LOOP AT i_component INTO wa_component.
    MOVE wa_component-name TO wa_component_str-name.
    wa_component_str-type ?= cl_abap_datadescr=>describe_by_name( lc_string ).
    lo_typedescr ?= cl_abap_datadescr=>describe_by_name( lc_string ).
    APPEND wa_component_str TO i_component_str.
  ENDLOOP. " LOOP AT i_component INTO wa_component

  CLEAR : wa_frow_str.
  TRY.
      wa_frow_str = cl_abap_structdescr=>create( p_components = i_component_str ).
    CATCH cx_sy_struct_creation .
  ENDTRY.

*  ** Create the Internal Table structure
  IF wa_frow_str IS NOT INITIAL.
    CLEAR : i_tab_str.
    TRY.
        i_tab_str = cl_abap_tabledescr=>create( p_line_type  = wa_frow_str ).
      CATCH cx_sy_table_creation .
    ENDTRY.
  ENDIF. " IF wa_frow_str IS NOT INITIAL


  IF i_tab IS NOT INITIAL.
    CREATE DATA gt_tab_str TYPE HANDLE i_tab_str. " Internal ID of an object
    ASSIGN gt_tab_str->* TO <gfs_tab_str>.
    CREATE DATA wa_row_str LIKE LINE OF <gfs_tab_str>.
    ASSIGN wa_row_str->* TO <gfs_row_str>.
  ENDIF. " IF i_tab IS NOT INITIAL


************************Appending data to character table.

  DESCRIBE TABLE i_component_str LINES gv_val_index.
  lv_count = 1.
  DO gv_val_index TIMES.
    READ TABLE i_component_str INTO wa_component_str INDEX lv_count. " Binary search not done as it contains column name & seq
    IF sy-subrc IS INITIAL.
      ASSIGN COMPONENT lv_count OF STRUCTURE <gfs_row_str> TO <gfs_fld>.
    ENDIF. " IF sy-subrc IS INITIAL
*** get the data element of the field name.

***  Cannot sort and perform binary search , as this table contains the field name.
    CLEAR wa_fdtl.
    READ TABLE i_fdtl ASSIGNING <gfs_fdtl> WITH KEY fieldname = wa_component_str-name BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      CONCATENATE wa_component_str-name '/' <gfs_fdtl>-rollname INTO lv_component_field.
    ENDIF. " IF sy-subrc IS INITIAL

    MOVE lv_component_field TO <gfs_fld>.
    lv_count = lv_count + 1.

  ENDDO.

  APPEND <gfs_row_str> TO <gfs_tab_str>.


*** Appending the field description.
  lv_count = 1.
  DO gv_val_index TIMES.
    READ TABLE i_component_str INTO wa_component_str INDEX lv_count. " no binary search done it contains field name .
    IF sy-subrc IS INITIAL.
      ASSIGN COMPONENT lv_count OF STRUCTURE <gfs_row_str> TO <gfs_fld>.
    ENDIF. " IF sy-subrc IS INITIAL
*** get the data element of the field name.

    CLEAR wa_fdtl.
    READ TABLE i_fdtl ASSIGNING <gfs_fdtl> WITH KEY fieldname = wa_component_str-name BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE <gfs_fdtl>-scrtext_l TO <gfs_fld>.
    ENDIF. " IF sy-subrc IS INITIAL

    lv_count = lv_count + 1.

  ENDDO.
  APPEND <gfs_row_str> TO <gfs_tab_str>.


** Appending the field values .

  LOOP AT <gfs_tab_temp> ASSIGNING <gfs_row_temp>.
    MOVE-CORRESPONDING <gfs_row_temp> TO <gfs_row_str>.
*---> Begin of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
    LOOP AT li_status ASSIGNING <lfs_status>.
      ASSIGN COMPONENT <lfs_status>-sel_low OF STRUCTURE <gfs_row_str> TO <gfs_fld>.
      IF <gfs_fld> IS ASSIGNED .
        CONCATENATE  '''' <gfs_fld> INTO lv_str.
        <gfs_fld> = lv_str.
        UNASSIGN <gfs_fld>.
        CLEAR : lv_str.
      ENDIF. " IF <gfs_fld> IS ASSIGNED
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
*<--- End of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
    APPEND <gfs_row_str> TO <gfs_tab_str>.
*<--- Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.
    gv_tab_counter = gv_tab_counter + 1 .
*<--- End of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.
  ENDLOOP. " LOOP AT <gfs_tab_temp> ASSIGNING <gfs_row_temp>


ENDFORM. " F_CREATE_CHAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_APPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_appl .

  DATA:  lv_file_name     TYPE string .
  DATA: li_file_table  TYPE rsanm_file_table,
        lwa_file_table TYPE rsanm_file_line.
  DATA : lv_count TYPE i. " Count of type Integers
  DATA : lv_tab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab, " Tab of type Character
         lv_ret TYPE c VALUE cl_abap_char_utilities=>cr_lf.          " Ret of type Character

  lv_file_name = p_affile.

  CLEAR : gv_val_index.
  DESCRIBE TABLE i_component LINES gv_val_index.

** Copying the data from dynamic internal table to static internal table .
**  so that the data can be transfered to the desired location.
  LOOP AT <gfs_tab_str> ASSIGNING <gfs_row_str>.
    lv_count = 1.
    DO gv_val_index TIMES.
      ASSIGN COMPONENT lv_count OF STRUCTURE <gfs_row_str> TO <gfs_desc>.
      IF lwa_file_table IS INITIAL.
        lwa_file_table = <gfs_desc>.
      ELSE. " ELSE -> IF lwa_file_table IS INITIAL
        CONCATENATE lwa_file_table <gfs_desc> INTO lwa_file_table  SEPARATED BY lv_tab.
      ENDIF. " IF lwa_file_table IS INITIAL
      UNASSIGN <gfs_desc>.
      lv_count = lv_count + 1.
    ENDDO.
    CONCATENATE lv_ret lwa_file_table INTO lwa_file_table.
    APPEND lwa_file_table TO li_file_table.
    CLEAR lwa_file_table.
  ENDLOOP. " LOOP AT <gfs_tab_str> ASSIGNING <gfs_row_str>

  IF li_file_table IS NOT INITIAL.

* Open the file path, to copy data .
    OPEN DATASET lv_file_name FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
    IF sy-subrc = 0.
**     Transfer of data.
      LOOP AT li_file_table INTO lwa_file_table .
        TRANSFER lwa_file_table TO lv_file_name.
      ENDLOOP. " LOOP AT li_file_table INTO lwa_file_table
      CLOSE DATASET lv_file_name.
      WRITE:/ TEXT-070 , 20 lv_file_name.
    ELSE. " ELSE -> IF sy-subrc = 0
      WRITE:/ TEXT-071 , lv_file_name.
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF li_file_table IS NOT INITIAL

  IF p_chk1 NE 'X'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_chk1 NE 'X'

ENDFORM. " F_SAVE_APPL
*&---------------------------------------------------------------------*
*&      Form  F_GET_PRES_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_pres_file .
  DATA : lv_filename_string TYPE string, " Filename
         lv_path            TYPE string,            " File path
         lv_fullpath        TYPE string,        " Full path
         lv_action          TYPE i.               " Action of type Integers

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    CHANGING
      filename                  = lv_filename_string
      path                      = lv_path
      fullpath                  = lv_fullpath
      user_action               = lv_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.

  p_file = lv_fullpath.

ENDFORM. " F_GET_PRES_FILE
*&---------------------------------------------------------------------*
*&      Form  F_GET_APP_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_app_file CHANGING  fp_afpath TYPE  filepath-pathintern. " Logical path name
** Get the file path for Application server.
  TYPES : BEGIN OF lty_pathtext,
            pathintern TYPE   pathtext-pathintern, " Logical path name
            pathname   TYPE   pathtext-pathname,   " Short description of logical file path
          END OF lty_pathtext.

  DATA : li_pathtext TYPE TABLE OF lty_pathtext.

  DATA : li_retval  TYPE STANDARD TABLE OF ddshretval, "Return records
         lwa_return TYPE ddshretval.                   "Return records

  CONSTANTS: lc_path TYPE dfies-fieldname VALUE 'PATHINTERN', " Field Name
             lc_s    TYPE char1 VALUE 'S'.                               "Value Org
**        This table stores the logical file name and description .

  SELECT pathintern " Logical path name
      pathname      " Short description of logical file path
    FROM pathtext   " Logical File Path Names
    INTO TABLE li_pathtext
    WHERE language = sy-langu.

    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = lc_path
          dynpprog        = sy-repid
          value_org       = lc_s
        TABLES
          value_tab       = li_pathtext
          return_tab      = li_retval
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      IF sy-subrc IS INITIAL.
        READ TABLE li_retval INTO lwa_return INDEX 1 .
        IF sy-subrc IS INITIAL.
          fp_afpath  =  lwa_return-fieldval.
        ELSE. " ELSE -> IF sy-subrc IS INITIAL
          CLEAR fp_afpath.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL


ENDFORM. " F_GET_APP_FILE
*--------------*
*&      Form  F_EMAIL_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_email_validation .


*** Validation for Email ID.
  DATA : lwa_address TYPE sx_address.
  CONSTANTS : lc_type TYPE sx_addr_type VALUE 'INT'.

  lwa_address-type = lc_type.
  lwa_address-address = p_mail.



  CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
    EXPORTING
      address_unstruct    = lwa_address
    EXCEPTIONS
      error_address_type  = 1
      error_address       = 2
      error_group_address = 3
      OTHERS              = 4.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e066 DISPLAY LIKE 'I'. " Enter Valid Email-ID
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_EMAIL_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validation .

  CONSTANTS : lc_ucomm TYPE sy-ucomm VALUE 'ONLI'. " Function code that PAI triggered

  IF p_kschl IS INITIAL.
    MESSAGE e068 DISPLAY LIKE TEXT-052. " Condition Type not entered
  ENDIF. " IF p_kschl IS INITIAL

  IF p_tab IS INITIAL.
    MESSAGE e067 DISPLAY LIKE TEXT-052. " Condition Table not entered
  ENDIF. " IF p_tab IS INITIAL

  IF p_mail IS NOT INITIAL.
    PERFORM f_email_validation.
  ENDIF. " IF p_mail IS NOT INITIAL

  IF sy-ucomm = lc_ucomm.

    IF p_chk2 = 'X'.
      IF p_pres = 'X' AND p_file IS INITIAL.
        MESSAGE e009 DISPLAY LIKE 'I'. " Presentation server file has not been entered
      ENDIF. " IF p_pres = 'X' AND p_file IS INITIAL

      IF p_app = 'X' .
        IF  p_affile IS INITIAL. " final file path.
          MESSAGE  e073 DISPLAY LIKE 'I'.
        ENDIF. " IF p_affile IS INITIAL
        IF p_afpath IS INITIAL.
          MESSAGE e072 DISPLAY LIKE 'I'.
        ENDIF. " IF p_afpath IS INITIAL
        IF p_afile IS INITIAL.
          MESSAGE e010 DISPLAY LIKE 'I'. " Application server file has not been entered
        ENDIF. " IF p_afile IS INITIAL
      ENDIF. " IF p_app = 'X'

      IF p_email = 'X' AND p_mail IS INITIAL.
        MESSAGE e066 DISPLAY LIKE 'I'. " Enter Valid Email-ID
      ENDIF. " IF p_email = 'X' AND p_mail IS INITIAL
    ENDIF. " IF p_chk2 = 'X'

    IF p_tab IS INITIAL.
      MESSAGE e067 DISPLAY LIKE 'I'. " Condition Table not entered
    ENDIF. " IF p_tab IS INITIAL
  ENDIF. " IF sy-ucomm = lc_ucomm


ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen .

  LOOP AT SCREEN.
    IF p_rdat IS NOT INITIAL.
      IF screen-group1 = 'M8'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M8'
      IF screen-group1 = 'M9'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M9'
    ELSEIF p_rdatbi IS NOT INITIAL.
      IF screen-group1 = 'M8'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M8'
      IF screen-group1 = 'M9'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M9'

    ENDIF. " IF p_rdat IS NOT INITIAL

    IF  p_pres = 'X'. "   Display Presentation server file path
      IF screen-group1 = 'M1'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M1'
      IF screen-group1 = 'M2'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M2'
      IF screen-group1 = 'M3'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M3'
    ELSEIF p_app = 'X'. "       Display Application server File path
      IF screen-group1 = 'M1'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M1'
      IF screen-group1 = 'M2' AND screen-name <> 'P_AFFILE'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M2' AND screen-name <> 'P_AFFILE'
      IF screen-group1 = 'M2' AND screen-name = 'P_AFFILE'.
        screen-input = '0'.
        screen-output = '1'.
        screen-active = '1'.

        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M2' AND screen-name = 'P_AFFILE'
      IF screen-group1 = 'M3'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M3'
    ELSEIF p_email = 'X'. "        Display Email Address input field.
      IF screen-group1 = 'M1'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M1'
      IF screen-group1 = 'M2'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M2'
      IF screen-group1 = 'M3'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M3'
    ENDIF. " IF p_pres = 'X'
*---> Begin of insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
    IF gv_srep_flag = 'X'.
      IF screen-name = 'S_SREP-LOW'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = 'S_SREP-LOW'
      IF screen-name = 'S_SREP-HIGH'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = 'S_SREP-HIGH'
      IF screen-name = '%_S_SREP_%_APP_%-TEXT'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-TEXT'
      IF screen-name = '%_S_SREP_%_APP_%-OPTI_PUSH'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-OPTI_PUSH'
      IF screen-name = '%_S_SREP_%_APP_%-TO_TEXT'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-TO_TEXT'
      IF screen-name = '%_S_SREP_%_APP_%-VALU_PUSH'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-VALU_PUSH'
    ELSE. " ELSE -> IF gv_srep_flag = 'X'
      IF screen-name = 'S_SREP-LOW'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN .
      ENDIF. " IF screen-name = 'S_SREP-LOW'

      IF screen-name = 'S_SREP-HIGH'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN .
      ENDIF. " IF screen-name = 'S_SREP-HIGH'

      IF screen-name = '%_S_SREP_%_APP_%-TEXT'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-TEXT'
      IF screen-name = '%_S_SREP_%_APP_%-OPTI_PUSH'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-OPTI_PUSH'
      IF screen-name = '%_S_SREP_%_APP_%-TO_TEXT'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-TO_TEXT'
      IF screen-name = '%_S_SREP_%_APP_%-VALU_PUSH'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%_S_SREP_%_APP_%-VALU_PUSH'
    ENDIF. " IF gv_srep_flag = 'X'
*<--- End of Insert for D2_OTC_RDD_0028/Defect_913 by VCHOUDH.


    IF p_chk2 IS NOT INITIAL.
      IF screen-name = '%B010026_BLOCK_1000'.
        screen-input = '1'.
        screen-output = '1'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%B010026_BLOCK_1000'



    ELSE. " ELSE -> IF p_chk2 IS NOT INITIAL

      IF screen-name = '%B010026_BLOCK_1000'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = '%B010026_BLOCK_1000'
      IF screen-group1 = 'M1'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M1'
      IF screen-group1 = 'M2'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M2'
      IF screen-group1 = 'M3'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'M3'
      IF screen-name = 'P_PRES'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = 'P_PRES'
      IF screen-name = 'P_APP'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = 'P_APP'
      IF screen-name = 'P_EMAIL'.
        screen-input = '0'.
        screen-output = '0'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = 'P_EMAIL'
    ENDIF. " IF p_chk2 IS NOT INITIAL


  ENDLOOP. " LOOP AT SCREEN


ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_GET_FULL_FILE_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_AFPATH  text
*      -->P_P_AFILE  text
*      <--P_P_AFFILE  text
*----------------------------------------------------------------------*
FORM f_get_full_file_path  USING    fp_p_afpath TYPE filepath-pathintern " Logical path name
                            CHANGING  fp_p_afile TYPE rlgrap-filename    " Local file for upload/download
                                      fp_p_affile TYPE rlgrap-filename.  " Local file for upload/download

  CONSTANTS : lc_ext  TYPE char4 VALUE '.XLS', " Ext of type CHAR4
              lc_ext1 TYPE char5 VALUE '.XLSX', " Ext1 of type CHAR5
              lc_ext2 TYPE char4 VALUE '.TXT'. " Ext2 of type CHAR4


*---> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.
  IF p_xls = 'X'.
    IF fp_p_afile IS NOT INITIAL.

      TRANSLATE fp_p_afile TO UPPER CASE.

      FIND lc_ext IN fp_p_afile.
      IF sy-subrc IS NOT INITIAL.
        FIND lc_ext1 IN fp_p_afile.
        IF sy-subrc IS NOT INITIAL.

          MESSAGE i071 . " File should have extension .XLS
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

        CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
          EXPORTING
            client                     = sy-mandt
            logical_path               = fp_p_afpath
            operating_system           = sy-opsys
            file_name                  = fp_p_afile
          IMPORTING
            file_name_with_path        = fp_p_affile
          EXCEPTIONS
            path_not_found             = 1
            missing_parameter          = 2
            operating_system_not_found = 3
            file_system_not_found      = 4
            OTHERS                     = 5.
*  IF sy-subrc <> 0.
*  ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF fp_p_afile IS NOT INITIAL

  ELSEIF p_txt = 'X'.

    IF fp_p_afile IS NOT INITIAL.

      TRANSLATE fp_p_afile TO UPPER CASE.

      FIND lc_ext2 IN fp_p_afile.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE i074 . " File should have extension .TXT
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ELSE. " ELSE -> IF fp_p_afile IS NOT INITIAL

      CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
        EXPORTING
          client                     = sy-mandt
          logical_path               = fp_p_afpath
          operating_system           = sy-opsys
          file_name                  = fp_p_afile
        IMPORTING
          file_name_with_path        = fp_p_affile
        EXCEPTIONS
          path_not_found             = 1
          missing_parameter          = 2
          operating_system_not_found = 3
          file_system_not_found      = 4
          OTHERS                     = 5.
*  IF sy-subrc <> 0.
*  ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF fp_p_afile IS NOT INITIAL
  ENDIF. " IF p_xls = 'X'


*<--- End of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.



ENDFORM. " F_GET_FULL_FILE_PATH
*&---------------------------------------------------------------------*
*&      Form  GET_SALES_REP_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sales_rep_info .

  DATA :li_dynpread  TYPE TABLE OF dynpread, " Fields of the current screen (with values)
        lwa_dynpread TYPE dynpread.         " Fields of the current screen (with values)
  DATA : lv_string TYPE gstru. " Generated DDIC table for LIS, conditions, messages
  CONSTANTS : lc_kschl TYPE dynfnam VALUE 'P_KSCHL', " Field name
              lc_tab   TYPE dynfnam VALUE 'P_TAB'.   " Field name

  IF p_kschl IS INITIAL OR p_tab IS INITIAL.
    lwa_dynpread-fieldname = lc_kschl.
    APPEND lwa_dynpread TO li_dynpread.
    CLEAR lwa_dynpread.
    lwa_dynpread-fieldname = lc_tab.
    APPEND lwa_dynpread TO li_dynpread.
  ENDIF. " IF p_kschl IS INITIAL OR p_tab IS INITIAL


*  fetching the values of the field in runtime .
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = li_dynpread.


  LOOP AT li_dynpread INTO lwa_dynpread.
    IF lwa_dynpread-fieldname = lc_kschl.
      p_kschl = lwa_dynpread-fieldvalue.
      TRANSLATE p_kschl TO UPPER CASE.
    ENDIF. " IF lwa_dynpread-fieldname = lc_kschl
    IF lwa_dynpread-fieldname = lc_tab.

      p_tab = lwa_dynpread-fieldvalue.
      TRANSLATE p_tab TO UPPER CASE.
    ENDIF. " IF lwa_dynpread-fieldname = lc_tab
  ENDLOOP. " LOOP AT li_dynpread INTO lwa_dynpread

* Begin of Change for Sctask:SCTASK0728808 and Defect:6955
* earlier kotabnr is value NUMC(3) now its changed to CHAR3
* so if initial just adding 000 so that there is no dump
* when using cl_abap_typedescr=>describe_by_name
  IF p_tab IS INITIAL.
    p_tab = '000'.
  ENDIF.
* End of Change for Sctask:SCTASK0728808 and Defect:6955

  CONCATENATE 'A' p_tab INTO lv_string.
  gv_table = lv_string.

*  Get Structure of the table "   Condition table .

  wa_row ?= cl_abap_typedescr=>describe_by_name( p_name = gv_table ).

  IF wa_row IS NOT INITIAL.
    i_component = wa_row->get_components( ).
  ENDIF. " IF wa_row IS NOT INITIAL

  READ TABLE i_component INTO wa_component WITH KEY  name = 'KUNNR'.
  IF sy-subrc IS INITIAL.
    READ TABLE i_component INTO wa_component WITH KEY name = 'MATNR'.
    IF sy-subrc IS INITIAL.
      gv_srep_flag = 'X'.
    ENDIF. " IF sy-subrc IS INITIAL
*  ELSE. " ELSE -> IF sy-subrc IS INITIAL
*  clear gv_srep_flag .
  ENDIF. " IF sy-subrc IS INITIAL

  READ TABLE i_component INTO wa_component WITH KEY name = 'KUNAG'. "   Sold-to-party
  IF sy-subrc IS INITIAL.
    READ TABLE i_component INTO wa_component WITH KEY name = 'MATNR'.
    IF sy-subrc IS INITIAL.
      gv_srep_flag = 'X'.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL
  READ TABLE i_component INTO wa_component WITH KEY name = 'KUNWE'. "  Ship-to-party
  IF sy-subrc IS INITIAL.
    READ TABLE i_component INTO wa_component WITH KEY name = 'MATNR'.
    IF sy-subrc IS INITIAL.
      gv_srep_flag = 'X'.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL


ENDFORM. " GET_SALES_REP_INFO
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       This subroutine performs the authorization check for sales org
*       and distribution channel.
*----------------------------------------------------------------------*
FORM f_authorization_check USING fp_trange TYPE rsds_trange.

  TYPES : BEGIN OF lty_vkorg,
            vkorg TYPE vkorg, " Sales Organization
          END OF lty_vkorg,

          BEGIN OF lty_vtweg,
            vtweg TYPE vtweg, " Distribution Channel
          END OF lty_vtweg.

  DATA : li_frange TYPE rsds_frange_t,                              " Internal table for Free selection value
         lr_vtweg  TYPE rsds_selopt_t,                              " Range table for select option of distribution channel
         li_vtweg  TYPE STANDARD TABLE OF lty_vtweg INITIAL SIZE 0, " Internal table for valid distribution channel
         lr_vkorg  TYPE rsds_selopt_t,                              " Range table fot select option of sales organization
         li_vkorg  TYPE STANDARD TABLE OF lty_vkorg INITIAL SIZE 0. " Internal table for valid sales organization


  FIELD-SYMBOLS : <lfs_vtweg>  TYPE lty_vtweg,   " Work area for distribution channel
                  <lfs_trange> TYPE rsds_range,  " Work area for range table
                  <lfs_frange> TYPE rsds_frange, " Work area for free selection value
                  <lfs_vkorg>  TYPE lty_vkorg.   " Work area for sales organization

  CONSTANTS : lc_vkorg      TYPE fieldname VALUE 'VKORG',      " Field Name
              lc_vtweg      TYPE fieldname VALUE 'VTWEG',      " Field Name
              lc_spart      TYPE char5     VALUE 'SPART',      " Spart of type CHAR5
              lc_actvt      TYPE char5     VALUE 'ACTVT',      " Actvt of type CHAR5
              lc_v_konh_vko TYPE char10    VALUE 'V_KONH_VKO', " V_konh_vko of type CHAR10
              lc_all        TYPE char1     VALUE '*',          " All of type CHAR1
              lc_disp       TYPE char2     VALUE '03',         " Disp of type CHAR2
*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#2158 by APODDAR
              lc_zotc0028   TYPE char10    VALUE 'ZOTC0028'. " Zotc0028 of type CHAR10
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#2158 by APODDAR

*** Get the values to check authorization
* Get the Dynamic values
  READ TABLE fp_trange ASSIGNING <lfs_trange> INDEX 1.
  IF <lfs_trange> IS ASSIGNED.
    li_frange[] = <lfs_trange>-frange_t.
    IF li_frange[] IS NOT INITIAL.

** Sales Organization -
*** No need for Binary search as the table will contain at max 10 records.
      READ TABLE li_frange ASSIGNING <lfs_frange> WITH KEY fieldname = lc_vkorg.
      IF sy-subrc = 0.
        lr_vkorg = <lfs_frange>-selopt_t.
*        IF lr_vkorg[] IS NOT INITIAL.  " Defect 2158
**      Get all the sales organizations from TVKO table which are requested from user.
        SELECT vkorg " Sales Organization
          INTO TABLE li_vkorg
          FROM tvko  " Organizational Unit: Sales Organizations
          WHERE vkorg IN lr_vkorg.
          IF sy-subrc = 0.
            SORT li_vkorg BY vkorg.
          ENDIF. " IF sy-subrc = 0
*        ENDIF. " if lr_vkorg[] is not INITIAL  " Defect 2158
        ENDIF. " IF sy-subrc = 0

** Distribution Channel -
*** No need for Binary search as the table will contain at max 10 records.
        READ TABLE li_frange ASSIGNING  <lfs_frange> WITH KEY fieldname = lc_vtweg.
        IF sy-subrc = 0.
          lr_vtweg = <lfs_frange>-selopt_t.
          IF lr_vtweg[] IS NOT INITIAL.
**      Get all the distribution channels from TVTW table which are requested from user.
            SELECT vtweg " Distribution Channel
              INTO TABLE li_vtweg
              FROM tvtw  " Organizational Unit: Distribution Channels
              WHERE vtweg IN lr_vtweg.
              IF sy-subrc = 0.
                SORT li_vtweg BY vtweg.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF lr_vtweg[] IS NOT INITIAL
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF li_frange[] IS NOT INITIAL
      ENDIF. " IF <lfs_trange> IS ASSIGNED

* If no distribution channel is entered then authorization will check only for sales organization
*& --> Begin of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR
*  IF li_vtweg[] IS INITIAL
* AND  li_vkorg[] IS NOT INITIAL.

*& <-- End   of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR

* Check the Authorization for all the sales organization requested.

      LOOP AT li_vkorg ASSIGNING <lfs_vkorg>.

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#2158 by APODDAR

** Check the authorization object ZOTC0028
        AUTHORITY-CHECK OBJECT lc_zotc0028
        ID lc_vkorg FIELD <lfs_vkorg>-vkorg
        ID lc_actvt FIELD lc_disp.
        IF sy-subrc NE 0.
          MESSAGE i924 WITH <lfs_vkorg>-vkorg.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF sy-subrc NE 0

*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#2158 by APODDAR

*& --> Begin of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR

** Check the authorization object V_KONH_VKO
*      AUTHORITY-CHECK OBJECT lc_v_konh_vko
*      ID lc_vkorg FIELD <lfs_vkorg>-vkorg
*      ID lc_vtweg FIELD lc_all
*      ID lc_spart FIELD lc_all
*      ID lc_actvt FIELD lc_disp.
*      IF sy-subrc NE 0.
*        MESSAGE e924 WITH <lfs_vkorg>-vkorg.
*        LEAVE LIST-PROCESSING.
*      ENDIF. " IF sy-subrc NE 0

*& <-- End   of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR

      ENDLOOP. " LOOP AT li_vkorg ASSIGNING <lfs_vkorg>

** If no sales organization is entered then authorization will check only for distribution channel
*& --> Begin of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR
*  ELSEIF li_vkorg[] IS INITIAL
*    AND li_vtweg[] IS NOT INITIAL.
*   ELSEIF li_vkorg[] IS INITIAL.
** Check the Authorization for all the sales organization requested.
*    LOOP AT li_vtweg ASSIGNING <lfs_vtweg>.
** Check the authorization object V_KONH_VKO
*      AUTHORITY-CHECK OBJECT lc_v_konh_vko
*      ID lc_vkorg FIELD lc_all
*      ID lc_vtweg FIELD <lfs_vtweg>-vtweg
*      ID lc_spart FIELD lc_all
*      ID lc_actvt FIELD lc_disp.
*      IF sy-subrc NE 0.
*        MESSAGE e922 WITH <lfs_vtweg>-vtweg.
*        LEAVE LIST-PROCESSING.
*      ENDIF. " IF sy-subrc NE 0
*    ENDLOOP. " LOOP AT li_vtweg ASSIGNING <lfs_vtweg>
*
** If both sales organization and distribution channel is entered then check authorization for all combination.
*  ELSEIF li_vkorg[] IS NOT INITIAL
*  AND li_vtweg[] IS NOT INITIAL.
*    LOOP AT li_vkorg ASSIGNING <lfs_vkorg>.
*      LOOP AT li_vtweg ASSIGNING <lfs_vtweg>.
*
* Check the authorization object V_KONH_VKO
*        AUTHORITY-CHECK OBJECT lc_v_konh_vko
*        ID lc_vkorg FIELD <lfs_vkorg>-vkorg
*        ID lc_vtweg FIELD <lfs_vtweg>-vtweg
*        ID lc_spart FIELD lc_all
*        ID lc_actvt FIELD lc_disp.
*        IF sy-subrc NE 0.
*          MESSAGE e923 WITH <lfs_vkorg>-vkorg <lfs_vtweg>-vtweg.
*          LEAVE LIST-PROCESSING.
*        ENDIF. " IF sy-subrc NE 0
*
*      ENDLOOP. " LOOP AT li_vtweg ASSIGNING <lfs_vtweg>
*    ENDLOOP. " LOOP AT li_vkorg ASSIGNING <lfs_vkorg>
*
*  ELSE. " ELSE -> IF sy-subrc NE 0
* Check the authorization object V_KONH_VKO
*    AUTHORITY-CHECK OBJECT lc_v_konh_vko
*    ID lc_vkorg FIELD lc_all
*    ID lc_vtweg FIELD lc_all
*    ID lc_spart FIELD lc_all
*    ID lc_actvt FIELD lc_disp.
*    IF sy-subrc NE 0.
*      MESSAGE e921.
*      LEAVE LIST-PROCESSING.
*    ENDIF. " IF sy-subrc NE 0
*
*  ENDIF. " IF li_vtweg[] IS INITIAL

*& <-- End   of Delete for D2_OTC_RDD_0028_Defect#2158 by APODDAR


ENDFORM. " F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK_KSCHL
*&---------------------------------------------------------------------*
*       Check the Authorization of user for accessing condition type
*----------------------------------------------------------------------*
FORM f_authorization_check_kschl .

  CONSTANTS : lc_kschl      TYPE char5     VALUE 'KSCHL',      " Kschl of type CHAR5
              lc_actvt      TYPE char5     VALUE 'ACTVT',      " Actvt of type CHAR5
              lc_v_konh_vks TYPE char10    VALUE 'V_KONH_VKS', " V_konh_vks of type CHAR10
              lc_all        TYPE char1     VALUE '*',          " All of type CHAR1
              lc_disp       TYPE char2     VALUE '03'.         " Disp of type CHAR2

  AUTHORITY-CHECK OBJECT lc_v_konh_vks
  ID lc_kschl FIELD p_kschl
  ID lc_actvt FIELD lc_disp.
  IF  sy-subrc NE 0.
    MESSAGE e920 WITH p_kschl.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_AUTHORIZATION_CHECK_KSCHL
*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_top_of_pages .
*ALV Header declarations
* title
  wa_header-typ  = 'H'.
  wa_header-info = TEXT-058.
  APPEND wa_header TO i_header.
  CLEAR wa_header.

* rows
  wa_header-typ  = 'S'.
  CONCATENATE TEXT-059 p_kschl INTO wa_header-info SEPARATED BY space.
  APPEND wa_header TO i_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  CONCATENATE TEXT-060 wa_tmc1t-gstru
              TEXT-061 wa_tmc1t-gstxt INTO wa_header-info SEPARATED BY space.
  APPEND wa_header TO i_header.
  CLEAR: wa_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_header.

  FREE i_header.
  CLEAR wa_header.
ENDFORM.
