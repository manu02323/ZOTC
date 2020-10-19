FUNCTION zotc_bom_explosion.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      TBL_BOM_MAT TYPE  ZOTC_BOM_COMPONENTS_T OPTIONAL
*"      TBL_BOM_RES TYPE  ZOTC_T_BOM_COMPONENTS_RES OPTIONAL
*"      TBL_MESSAGE TYPE  ZOTC_T_MESSAGE OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_BOM_EXPLOSION                                     *
* TITLE      :  FM to determine BOM Components                         *
* DEVELOPER  :  Bhargav Gundabolu                                      *
* OBJECT TYPE:  Function Module                                        *
* SAP RELEASE:  SAP ERP                                                *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0185_Check Product Availability               *
*----------------------------------------------------------------------*
* DESCRIPTION: This function Module is to explode the BOM material     *
* and provide the Individual components for each BOM material          *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:
*----------------------------------------------------------------------*
* DATE          USER      TRANSPORT      DESCRIPTION
* ===========  ========  ==========    ================================*
* 23-Mar-2015   BGUNDAB   E2DK910950   INITIAL DEVELOPMENT
*----------------------------------------------------------------------*

  TYPES : lty_t_stpox TYPE STANDARD TABLE OF stpox. " BOM Items (Extended for List Displays)

  DATA: li_stb    TYPE lty_t_stpox,                 "local internal table of type
        lv_msg  TYPE char200,                       " Msg of type CHAR200
        lwa_message TYPE zotc_s_message,            " Structure for message
        lwa_bom   TYPE zotc_bom_components,         " Material Serial Number Combination structure
        lwa_bom_res TYPE zotc_s_bom_components_res. " Bom explosion components

  FIELD-SYMBOLS : <lfs_stb> TYPE stpox. " BOM Items (Extended for List Displays)

  LOOP AT tbl_bom_mat INTO lwa_bom.
    CLEAR li_stb.

    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        capid                 = space
        datuv                 = sy-datum
        mehrs                 = abap_true "'X'
        mtnrv                 = lwa_bom-matnr
        stlan                 = '5'
        stpst                 = 0
        svwvo                 = abap_true "'X'
        werks                 = lwa_bom-werks
      TABLES
        stb                   = li_stb
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.

    IF sy-subrc = 0.
      LOOP AT li_stb ASSIGNING <lfs_stb>.
        lwa_bom_res-idnrk = <lfs_stb>-idnrk.
        lwa_bom_res-posex =  lwa_bom-posex.
        lwa_bom_res-werks =  lwa_bom-werks.
        APPEND lwa_bom_res TO tbl_bom_res.
      ENDLOOP. " LOOP AT li_stb ASSIGNING <lfs_stb>
    ELSE. " ELSE -> IF sy-subrc = 0

      IF sy-msgid IS NOT INITIAL.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = sy-msgid
            lang      = sy-langu
            no        = sy-msgno
            v1        = sy-msgv1
            v2        = sy-msgv2
            v3        = sy-msgv3
            v4        = sy-msgv4
          IMPORTING
            msg       = lv_msg
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc = 0.
          lwa_message-msgtxt = lv_msg.
          APPEND lwa_message TO tbl_message.
          CLEAR lwa_message.
        ENDIF. " IF sy-subrc = 0
      ELSE. " ELSE -> IF sy-subrc = 0
        CONCATENATE text-002 lwa_bom-matnr text-003 lwa_bom-werks
                                              INTO lwa_message-msgtxt SEPARATED BY space.
        APPEND lwa_message TO tbl_message.
        CLEAR lwa_message.
      ENDIF. " IF sy-msgid IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT tbl_bom_mat INTO lwa_bom

ENDFUNCTION.
