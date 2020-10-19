*&---------------------------------------------------------------------*
*& Report ZOTC_OSS_2341606
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZOTC_OSS_2341606.
DATA gs_lord_scenario_id TYPE lord_scenario_id.
DATA gs_lord_scenario_it TYPE lord_scenario_it.
DATA gv_error TYPE xfeld VALUE space.

*==============================================================*
* Definition of the selection screen                                  *
*==============================================================*
PARAMETERS  insert RADIOBUTTON GROUP act.
PARAMETERS  delete RADIOBUTTON GROUP act.

*==============================================================*
* Selection of data                                                    *
*==============================================================*
START-OF-SELECTION.

  gs_lord_scenario_id-scenario_id = 'ESOA_DISMISS_ATP_GROUPCHECK'.
  gs_lord_scenario_it-language = 'E'.
  gs_lord_scenario_it-scenario_id = 'ESOA_DISMISS_ATP_GROUPCHECK'.
  gs_lord_scenario_it-scenario_text = 'DISMISS ATP GROUP CHECK'.

  IF insert IS NOT INITIAL.
    INSERT lord_scenario_id FROM gs_lord_scenario_id.
    IF sy-subrc <> 0.
      gv_error = 'X'.
    ENDIF.
    INSERT lord_scenario_it FROM gs_lord_scenario_it.
    IF sy-subrc <> 0.
      gv_error = 'X'.
    ENDIF.
  ENDIF.



  IF delete IS NOT INITIAL.
    DELETE lord_scenario_id FROM gs_lord_scenario_id.
    IF sy-subrc <> 0.
      gv_error = 'X'.
    ENDIF.

    DELETE lord_scenario_it FROM gs_lord_scenario_it.
    IF sy-subrc <> 0.
      gv_error = 'X'.
    ENDIF.

  ENDIF.

  IF gv_error = 'X'.
    WRITE 'No successful change to LORD_SCENARIO_ID'.
    ROLLBACK WORK.
  ELSE.
    WRITE 'LORD_SCENARIO_ID was changed successfully.'.
    COMMIT WORK.
  ENDIF.
