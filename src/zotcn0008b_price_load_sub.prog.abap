*&---------------------------------------------------------------------*
*&  Include           ZOTCC0008B_PRICE_LOAD_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0008_PRICE_LOAD_SUB                              *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0008_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-June-2012 SPURI   E1DK901614  INITIAL DEVELOPMENT                 *
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *
* 12-Oct-2012  SPURI   E1DK906586  Defect:264 Inc ALV count Size /
*                                  Defect:267 Corrected selection
*                                  from table KNA1
* 23-Oct-2012  SPURI   E1DK906586  Defect 1025 . Make Buying group
*                                  mandatory for A901 and A904
* 29-Oct-2012  SPURI   E1DK906586  Defect 1177 . Add check to verify
*                                  valid buying group exist in table
*                                  TVV1. Righ now Standard FM raises a
*                                  error and it halts the program. With
*                                  the new change , it will pass the
*                                  record in error log
* 05-Dec-2012  SPURI   E1DK906586  Defect 1955 .Remove # from End of rec
*                                  if any.
* 09-Jan-2013  SPURI   E1DK906586  Defect 2390 Add condition table A911
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*&---------------------------------------------------------------------*
form f_modify1_screen .
  loop at screen .
    if rb_pres ne c_true.
      if screen-group1    = c_groupmi3
         or screen-group1 = c_groupmi4
         or screen-group1 = c_groupmi6.
        screen-active = c_zero.
        modify screen.
      endif.
    else.
      if screen-group1 = c_groupmi3.
        screen-active = c_one.
        modify screen.
      endif.
    endif.
    if rb_app ne c_true.
      if screen-group1    = c_groupmi2
         or screen-group1 = c_groupmi5
         or screen-group1 = c_groupmi7.
        screen-active = c_zero.
        modify screen.
      endif.
    endif.
  endloop.
endform.                    " F_MODIFY1_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE1
*&---------------------------------------------------------------------*
* Load File into Internal table i_leg_tab
*&---------------------------------------------------------------------*
form f_read_file  .
  data:   lv_msg          type string, " message
          lv_leg_tab      type string, " legacy table record
          lv_datum        type datum,  " date YYYYMMDD format
          lv_filename     type string, " File name
          lwa_string      type ty_string. "Record

*12/05/2012 Start Of change by Shammi Defect 1955
  data:   c_nline(1) type c value   cl_abap_char_utilities=>newline .
*12/05/2012 End of Change by Shammi Defect 1955



  clear: gv_subrc,gv_header , gv_table,lv_filename.






*START OF DEFECT 1177
  select kvgr1
  from   tvv1
  into table i_tvv1.
  if sy-subrc = 0.

    sort i_tvv1 by kvgr1.

  endif.
*END OF DEFECT 1177


  if rb_pres = c_selected.
    lv_filename = p_phdr.
    gv_filename = p_phdr.
    gv_file     = p_phdr.
  elseif rb_app = c_selected.

    if rb_aphy = c_selected.

      lv_filename = p_ahdr.
      gv_filename = p_ahdr.
      gv_file     = p_ahdr.
    elseif rb_alog = c_selected.
      lv_filename = gv_filename.
      gv_file     = lv_filename.
    endif.
  endif.
* get condition table name from file name
  perform f_get_table_name.
* Presentation server
  if rb_pres = c_selected.
* read file
    call method cl_gui_frontend_services=>gui_upload
      exporting
        filename                = lv_filename
      changing
        data_tab                = i_string
      exceptions
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        others                  = 19.

    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno into lv_msg
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      write: / lv_msg, ':', lv_filename.
    else.
*populate internal tables based on condition table name
      case gv_table.
        when c_005.
          perform f_read_record_a005.
        when c_903.
          perform f_read_record_a903.
        when c_901.
          perform f_read_record_a901.
        when c_904.
          perform f_read_record_a904.
        when c_902.
          perform f_read_record_a902.
        when c_905.
          perform f_read_record_a905.
        when c_004.
          perform f_read_record_a004.
*START DEFECT  2390 01/08/2013
   when c_911.
          perform f_read_record_a911.
*END  DEFECT  2390 01/08/2013


        when others.
          message i000  with 'Invalid File Name.'(035).
          leave list-processing.
      endcase.

    endif.
    gv_file = lv_filename.
  else.
*App Server
    open dataset lv_filename for input in text mode encoding default.
    if sy-subrc ne 0.
      message i000  with 'Error in opening file.'(012).
      leave list-processing.
    else.
      while ( gv_subrc eq 0 ).
        clear lv_leg_tab.
        read dataset lv_filename into lwa_string-string.
        gv_subrc = sy-subrc.
        if gv_subrc = 0.
*12/05/2012 Start of change Shammi D#1955
          replace all occurrences of   CL_ABAP_CHAR_UTILITIES=>CR_LF(1) in lwa_string-string with space.
*12/05/2012 End of change Shammi D#1955
          append lwa_string to i_string.
        endif.
      endwhile.
    endif.
    close dataset lv_filename.

    case gv_table.
      when '005'.
        perform f_read_record_a005.
      when '903'.
        perform f_read_record_a903.
      when '901'.
        perform f_read_record_a901.
      when '904'.
        perform f_read_record_a904.
      when '902'.
        perform f_read_record_a902.
      when '905'.
        perform f_read_record_a905.
      when '004'.
        perform f_read_record_a004.
*START DEFECT 2390 01/08/2013
   when c_911.
          perform f_read_record_a911.
*END  DEFECT  2390 01/08/2013

      when others.
        message i000  with 'Invalid File Name.'(035).
        leave list-processing.
    endcase.
  endif.
endform.                    " F_UPLOAD_FILE1
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
* Display ALV Log
*&---------------------------------------------------------------------*
form f_display_summary .
  gv_no_success1  = gv_tot - gv_error.
  if rb_post = c_selected .
    gv_mode = 'Post Run'(033).
  else.
    gv_mode = 'Test Run'(032).
  endif.
  if rb_pres <> c_selected .
    if rb_post = c_selected.
      perform f_move using    gv_file
                     changing i_report[].
    endif.
  endif.
  perform f_display_summary_report1  using i_report[]
                                          gv_file
                                          gv_mode
                                          gv_no_success1
                                          gv_error.

endform.                    " F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*  Move file from TBP to Done Folder & creates Error file in Folder
*  Error with Failed records for re-processing
*&---------------------------------------------------------------------*
form f_move using fp_v_source type localfile
            changing fp_i_report type ty_t_report.

  data: lv_file   type localfile,   "File Name
        lv_name   type localfile,   "Path Name
        lv_return type sysubrc,     "Return Code
        lwa_report type ty_report,  "Report
        lv_data    type string,    "Output data string
        lwa_leg_tab_error type ty_leg_tab.


  call function '/SAPDMC/LSM_PATH_FILE_SPLIT'
    exporting
      pathfile = fp_v_source
    importing
      pathname = lv_file
      filename = lv_name.


  replace c_tobeprscd in lv_file with c_done_fold .
  concatenate lv_file lv_name into lv_file.
  perform f_file_move  using    fp_v_source
                                lv_file
                       changing lv_return.
  if lv_return is initial.
    gv_archive_gl_1 = lv_file.
  else.
    lwa_report-msgtyp = c_error.
    message i000 with 'Input file'(011)
                       lv_file
                      'not moved.'(013)
            into lwa_report-msgtxt.
    append lwa_report to fp_i_report.
    clear lwa_report.
  endif.


  if gv_error > 0.
    replace c_done_fold in lv_file with c_err_fold.
    open dataset lv_file for output in text mode encoding default.
    if sy-subrc ne 0.
      message i006. "Error Folder could not be opened
      exit.
    else.
      loop at i_leg_tab_err into lwa_leg_tab_error.
        concatenate
             lwa_leg_tab_error-kappl
             lwa_leg_tab_error-kschl
             lwa_leg_tab_error-vkorg
             lwa_leg_tab_error-vtweg
             lwa_leg_tab_error-kunnr
             lwa_leg_tab_error-matnr
             lwa_leg_tab_error-datab
             lwa_leg_tab_error-datbi
             lwa_leg_tab_error-prod
             lwa_leg_tab_error-zzkvgr1
             lwa_leg_tab_error-zzkvgr2
             into lv_data
             separated by c_tab.
        transfer lv_data to lv_file.
        clear lv_data.
      endloop.
    endif.
    close dataset lv_file.
  endif.
endform.                    " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
*    Creates Pricing Condition Records . Not released Function Modules
*     RV_CONDITION_COPY
*     RV_CONDITION_SAVE
*     RV_CONDITION_RESET
*     are warapped up into Z FM ZOTC_RV_CONDITION_COPY.
*&--------------------------------------------------------------------*
form f_upload_data .

  data : lwa_komg     type komg, " KOMG  Workarea
         lwa_komp     type komp, " KOMP  Workarea
         lwa_komv     type komv, " KOMV workarea
         lwa_komk     type komk, " KOMK workarea
         li_komv      type standard table of komv initial size 0, " internal table KOMV
         lv_date_from type datum, " Date YYYYMMDD format
         lv_date_to   type datum, " Date YYYYMMDD format
         lv_new_record," New Rec indicator
         lv_krech type t685a-krech.

*  FIELD-SYMBOLS : <lfs_mvke> TYPE ty_mvke,
*                  <lfs_kna1> TYPE ty_kna1.

  describe table i_leg_tab lines gv_tot.

  gv_tot = gv_tot + gv_skip.

  if i_leg_tab[] is not initial.


* Mapping from Legacy System to ECC

    if gv_table = c_005 or
       gv_table = c_901 or
       gv_table = c_902 or
       gv_table = c_004 or
       gv_table = c_903 or
*START DEFECT  2390 01/08/2013
       gv_table = c_911.
*END  DEFECT 2390 01/08/2013
      perform f_map_legacy.
    endif.


    if i_leg_tab[] is not initial.

      select kschl
      from   t685
      into table i_t685.
      if sy-subrc = 0.
      endif.


      select vkorg
      from   tvko
      into table i_tvko.
      if sy-subrc = 0.
      endif.


      select vtweg
      from   tvtw
      into table i_tvtw.
      if sy-subrc = 0.
      endif.

    endif.


    sort i_t685  ascending by kschl.
    sort i_tvko  ascending by vkorg.
    sort i_tvtw  ascending by vtweg.

    loop at i_leg_tab into wa_leg_tab.

      perform f_verify_date.
      if gv_error_check = c_selected.
        continue.
      endif.
      clear : lv_date_from , lv_date_to.
      lv_date_from = wa_leg_tab-datab.
      lv_date_to   = wa_leg_tab-datbi.

      clear lwa_komg.
      lwa_komg-vkorg   = wa_leg_tab-vkorg.
      lwa_komg-vtweg   = wa_leg_tab-vtweg.

*START DEFECT 2390 01/08/2013
      if gv_table = c_911.
        lwa_komg-kunwe   = wa_leg_tab-kunnr.
        lwa_komg-matnr   = wa_leg_tab-matnr.
      endif.
*END   DEFECT 2390 01/08/2013

      if gv_table = c_005.
        lwa_komg-kunnr   = wa_leg_tab-kunnr.
        lwa_komg-matnr = wa_leg_tab-matnr.
      endif.

      if gv_table = c_903.
        lwa_komg-kunnr   = wa_leg_tab-kunnr.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      endif.

      if gv_table = c_901.
        lwa_komg-zzkvgr1 = wa_leg_tab-zzkvgr1.
        lwa_komg-matnr = wa_leg_tab-matnr.
      endif.

      if gv_table = c_904.
        lwa_komg-zzkvgr1  = wa_leg_tab-zzkvgr1.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      endif.

      if gv_table = c_902.
        lwa_komg-zzkvgr2  = wa_leg_tab-zzkvgr2.
        lwa_komg-matnr = wa_leg_tab-matnr.
      endif.

      if gv_table = c_905.
        lwa_komg-zzkvgr2  = wa_leg_tab-zzkvgr2.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      endif.

      if gv_table = c_004.
        lwa_komg-matnr = wa_leg_tab-matnr.
      endif.

      clear lwa_komv.
      refresh li_komv[].
      lwa_komv-kappl = wa_leg_tab-kappl.
      lwa_komv-kschl = wa_leg_tab-kschl.
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *

      lwa_komv-kbetr = wa_leg_tab-kbetr.


      clear lv_krech.
      select single krech
             from   t685a
             into   lv_krech
             where  kschl = wa_leg_tab-kschl and
                    kappl = lwa_komv-kappl.

      if sy-subrc = 0.
        if lv_krech = 'A'.
          lwa_komv-kbetr = lwa_komv-kbetr * 10.
        endif.
      endif.

* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *
      lwa_komv-waers = wa_leg_tab-konwa.
      lwa_komv-kpein = wa_leg_tab-kpein.
      lwa_komv-kmein = wa_leg_tab-kmein.
      append lwa_komv to li_komv.



      if  rb_post = c_selected.
        call function 'ZOTC_RV_CONDITION_COPY'
          exporting
            application                 = lwa_komv-kappl
            condition_table             = gv_table
            condition_type              = wa_leg_tab-kschl
            date_from                   = lv_date_from
            date_to                     = lv_date_to
            enqueue                     = c_selected
            i_komk                      = lwa_komk
            i_komp                      = lwa_komp
            key_fields                  = lwa_komg
            maintain_mode               = c_mode_a
            no_authority_check          = c_selected
            keep_old_records            = c_selected
            overlap_confirmed           = c_selected
            no_db_update                = space
          importing
            e_komk                      = lwa_komk
            e_komp                      = lwa_komp
            new_record                  = lv_new_record
          tables
            copy_records                = li_komv
          exceptions
            enqueue_on_record           = 1
            invalid_application         = 2
            invalid_condition_number    = 3
            invalid_condition_type      = 4
            no_authority_ekorg          = 5
            no_authority_kschl          = 6
            no_authority_vkorg          = 7
            no_selection                = 8
            table_not_valid             = 9
            no_material_for_settlement  = 10
            no_unit_for_period_cond     = 11
            no_unit_reference_magnitude = 12
            invalid_condition_table     = 13
            others                      = 14.
        if sy-subrc = 0.
          perform f_log_msg.
        else.
          gv_error = gv_error + 1.
          append  wa_leg_tab to i_leg_tab_err.
          perform f_log_msg.
        endif.
      endif.
    endloop.
  endif.
endform.                    " F_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOG_ERROR
*&---------------------------------------------------------------------*
* Get Message Description
*&---------------------------------------------------------------------*
form f_log_msg.

  data : lwa_return type bapiret2, " bapi return
         lv_par1 type char50," parameter1
         lv_par2 type char50," parameter2
         lv_par3 type char50," parameter3
         lv_par4 type char50," parameter1
         lv_num  type bapiret2-number."message number

  clear : lwa_return ,
          lv_par1 ,
          lv_par2 ,
          lv_par3 ,
          lv_par4,
          lv_num.

  lv_par1 = syst-msgv1.
  lv_par2 = syst-msgv2.
  lv_par3 = syst-msgv3.
  lv_par4 = syst-msgv4.
  lv_num  = syst-msgno.

  call function 'BALW_BAPIRETURN_GET2'
    exporting
      type   = syst-msgty
      cl     = syst-msgid
      number = lv_num
      par1   = lv_par1
      par2   = lv_par2
      par3   = lv_par3
      par4   = lv_par4
    importing
      return = lwa_return.

  clear wa_report.

  wa_report-msgtyp = syst-msgty.

  if wa_report-msgtyp <> c_error.
    wa_report-msgtxt = text-022.
  else.
    wa_report-msgtxt = lwa_return-message.
  endif.



  concatenate wa_leg_tab-kappl
              wa_leg_tab-kschl
              wa_leg_tab-vkorg
              wa_leg_tab-vtweg
              wa_leg_tab-kunnr
              wa_leg_tab-matnr
              wa_leg_tab-datab
              wa_leg_tab-datbi
              wa_leg_tab-prod
              wa_leg_tab-zzkvgr1
              wa_leg_tab-zzkvgr2
             into gv_mkey separated by space.

  wa_report-key    = gv_mkey.
  append wa_report to i_report.
  clear wa_report.
endform.                    " F_LOG_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DATE
*&---------------------------------------------------------------------*
*      Check for valid date
*----------------------------------------------------------------------*
form f_check_date  using  fp_text
                          fp_date.
*                   CHANGING fp_return TYPE c.

  clear gv_return1.

  call function 'DATE_CHECK_PLAUSIBILITY'
    exporting
      date                      = fp_date
    exceptions
      plausibility_check_failed = 1
      others                    = 2.
*Invalid Date
  if sy-subrc <> 0.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = fp_text.
    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    gv_skip   = gv_skip + 1.
    append  wa_leg_tab to i_leg_tab_err.
*    fp_return = c_selected.
    gv_return1 = c_selected.
  endif.
endform.                    " F_CHECK_DATE
*&---------------------------------------------------------------------*
*&      Form  F_DATE_CONVERT
*&---------------------------------------------------------------------*
*    Convert Date from MM.DD.YYYY to YYYYMMDD
*----------------------------------------------------------------------*
form f_date_convert  using    fp_lv_date changing fp_date type datum.

  concatenate fp_lv_date+6(4)
              fp_lv_date+0(2)
              fp_lv_date+3(2)
  into        fp_date.
endform.                    " F_DATE_CONVERT
*&---------------------------------------------------------------------*
*&      Form  F_LEGACY_MATERIAL
*&---------------------------------------------------------------------*
*    populate internal table i_legacy_tab to be mapped to ECC materials
*----------------------------------------------------------------------*
form f_legacy_material using fp_matnr.
  clear wa_legacy_tab.
  wa_legacy_tab-object_type      = 'MARA'.
  wa_legacy_tab-source_key_value = fp_matnr.
  append wa_legacy_tab to i_legacy_tab.
endform.                    " F_LEGACY_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_MAP_LEGACY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_map_legacy .

  data : lwa_ecc_tab     type zzlegacy_ecc_translate,
         li_ecc_tab      type standard table of zzlegacy_ecc_translate
                         initial size 0.
  if cb_map = c_selected.
    refresh li_ecc_tab[].
    call function 'ZMDM_TRANSLATION_LEGACY_ECC'
      exporting
        im_translate               = 'E'
      tables
        tbl_input_tab              = i_legacy_tab
      changing
        tbl_return_tab             = li_ecc_tab
      exceptions
        no_ecc_value_found         = 1
        no_legacy_value_found      = 2
        invalid_translation_option = 3
        others                     = 4.


    sort li_ecc_tab ascending by source_key_value.

    loop at i_leg_tab assigning <fs_leg_tab>.
      clear lwa_ecc_tab.
      read table li_ecc_tab into lwa_ecc_tab
                            with key source_key_value = <fs_leg_tab>-matnr
                            binary search.
      if sy-subrc = 0.
        <fs_leg_tab>-matnr = lwa_ecc_tab-ecc_key_value.

        call function 'CONVERSION_EXIT_MATN1_INPUT'
          exporting
            input        = <fs_leg_tab>-matnr
          importing
            output       = <fs_leg_tab>-matnr
          exceptions
            length_error = 1
            others       = 2.

      else.
        call function 'CONVERSION_EXIT_MATN1_INPUT'
          exporting
            input        = <fs_leg_tab>-matnr
          importing
            output       = <fs_leg_tab>-matnr
          exceptions
            length_error = 1
            others       = 2.
      endif.
    endloop.

  else.
    loop at i_leg_tab assigning <fs_leg_tab>.
      call function 'CONVERSION_EXIT_MATN1_INPUT'
        exporting
          input        = <fs_leg_tab>-matnr
        importing
          output       = <fs_leg_tab>-matnr
        exceptions
          length_error = 1
          others       = 2.

    endloop.
  endif.
* Check if material is allowed for a given sales org / distribution channel
  refresh i_leg_tab_temp[].
  i_leg_tab_temp[] = i_leg_tab[].
  sort  i_leg_tab_temp ascending by matnr ascending vkorg ascending vtweg.
  delete adjacent duplicates from i_leg_tab_temp comparing matnr vkorg vtweg.


*START CHANGE Defect 267
* populate internal table i_leg_tab_temp1 for all entries for KNA1
  refresh i_leg_tab_temp1[].
  i_leg_tab_temp1[] = i_leg_tab[].
  sort  i_leg_tab_temp1 ascending by kunnr.
  delete adjacent duplicates from i_leg_tab_temp1 comparing kunnr.
*END CHANGE Defect 267

  refresh i_mvke[].
  if i_leg_tab_temp[] is not initial.
    select  matnr
            vkorg
            vtweg
    from mvke
    into table i_mvke
    for all entries in i_leg_tab_temp
    where   matnr =  i_leg_tab_temp-matnr and
            vkorg =  i_leg_tab_temp-vkorg and
            vtweg =  i_leg_tab_temp-vtweg.
    if sy-subrc = 0.
      sort i_mvke ascending by  matnr
                  ascending     vkorg
                  ascending     vtweg.

    endif.
  endif.


*START CHANGE Defect 267
*Get KNA1
  refresh i_kna1[].
  if i_leg_tab_temp1[] is not initial.
    if gv_table = c_005 or
       gv_table = c_903 or
*START DEFECT  2390 01/08/2013
       gv_table = c_911.
*END DEFECT 2390 01/08/2013
      select  kunnr
              aufsd
       from kna1
       into table i_kna1
       for all entries in i_leg_tab_temp1
       where   kunnr =  i_leg_tab_temp1-kunnr.
      if sy-subrc = 0.
        sort i_kna1 ascending by  kunnr.
      endif.
    endif.
  endif.
*END CHANGE Defect 267


endform.                    " F_MAP_LEGACY
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A005
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A005
*----------------------------------------------------------------------*
form f_read_record_a005 .

  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.


  loop at i_string into wa_string.
*skip header record
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi, lv_kbetr.
      split  wa_string-string at c_tab into
             wa_005-kappl
             wa_005-kschl
             wa_005-vkorg
             wa_005-vtweg
             wa_005-kunnr
             wa_005-matnr
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.




      wa_005-kbetr = lv_kbetr.

      wa_005-konwa = lv_konwa.
      wa_005-kpein = lv_kpein.
      wa_005-kmein = lv_kmein.





*convert from date from MM.DD.YYYY to YYYYMM DD
      perform f_date_convert using gv_datab
                             changing wa_005-datab.
*Check valid date
      perform f_check_date   using text-024 wa_005-datab.
*                             CHANGING gv_return1.
*Error skip record
      if gv_return1 = c_selected.
        continue.
      endif.

*convert to date from MM.DD.YYYY to YYYYMM DD
      perform f_date_convert using gv_datbi
                             changing wa_005-datbi.
*Check valid date
      perform f_check_date   using text-025 wa_005-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
*Error skip record
        continue.
      endif.

*populate material mapping table
      perform f_legacy_material using wa_005-matnr.
*convert customer to ECC format
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = wa_005-kunnr
        importing
          output = wa_005-kunnr.
      move-corresponding wa_005 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A005
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A903
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A903
*----------------------------------------------------------------------*
form f_read_record_a903 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.
  .
  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi , lv_kbetr.
      split  wa_string-string at c_tab into
             wa_903-kappl
             wa_903-kschl
             wa_903-vkorg
             wa_903-vtweg
             wa_903-kunnr
             wa_903-prod
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.


      wa_903-kbetr = lv_kbetr.
      wa_903-konwa = lv_konwa.
      wa_903-kpein = lv_kpein.
      wa_903-kmein = lv_kmein.


      perform f_date_convert using gv_datab
                             changing wa_903-datab.
      perform f_check_date   using text-024 wa_903-datab.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi
                             changing wa_903-datbi.
      perform f_check_date   using text-025 wa_903-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = wa_903-kunnr
        importing
          output = wa_903-kunnr.

      move-corresponding wa_903 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A903
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A901
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A901
*----------------------------------------------------------------------*
form f_read_record_a901 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.

  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi , lv_kbetr.
      split  wa_string-string at c_tab into
             wa_901-kappl
             wa_901-kschl
             wa_901-vkorg
             wa_901-vtweg
             wa_901-zzkvgr1
             wa_901-matnr
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.


      wa_901-kbetr = lv_kbetr.
      wa_901-konwa = lv_konwa.
      wa_901-kpein = lv_kpein.
      wa_901-kmein = lv_kmein.



      concatenate  wa_901-kappl
                   wa_901-kschl
                   wa_901-vkorg
                   wa_901-vtweg
                   wa_901-matnr
                   gv_datab
                   gv_datbi
                   wa_901-zzkvgr1
                  into gv_mkey separated by space.




      perform f_date_convert using gv_datab
                             changing wa_901-datab.
      perform f_check_date   using text-024 wa_901-datab.
*                            CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi
                             changing wa_901-datbi.
      perform f_check_date   using text-025 wa_901-datbi.
*                            CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

*Start of Defect 1025
      perform f_check_buygrp   using text-038 wa_901-zzkvgr1.

      if gv_return1 = c_selected.
        continue.
      endif.
*End   of Defect 1025

*Start of Defect 1177

      perform f_valid_buygrp   using text-039 wa_901-zzkvgr1.
      if gv_return1 = c_selected.
        continue.
      endif.
*End   of Defect 1177





      perform f_legacy_material using wa_901-matnr.
      move-corresponding wa_901 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A901
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A904
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A904
*----------------------------------------------------------------------*
form f_read_record_a904 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.

  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi , lv_kbetr.
      split  wa_string-string at c_tab into
             wa_904-kappl
             wa_904-kschl
             wa_904-vkorg
             wa_904-vtweg
             wa_904-zzkvgr1
             wa_904-prod
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.




      concatenate  wa_904-kappl
                   wa_904-kschl
                   wa_904-vkorg
                   wa_904-vtweg
                   gv_datab
                   gv_datbi
                   wa_904-prod
                   wa_904-zzkvgr1
                  into gv_mkey separated by space.








      wa_904-kbetr = lv_kbetr.
      wa_904-konwa = lv_konwa.
      wa_904-kpein = lv_kpein.
      wa_904-kmein = lv_kmein.



      perform f_date_convert using gv_datab
                             changing wa_904-datab.
      perform f_check_date   using text-024 wa_904-datab.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi changing wa_904-datbi.
      perform f_check_date   using text-025 wa_904-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

*Start of Defect 1025
      perform f_check_buygrp   using text-038 wa_904-zzkvgr1.
      if gv_return1 = c_selected.
        continue.
      endif.
*End   of Defect 1025


*Start of Defect 1177
      perform f_valid_buygrp   using text-039 wa_904-zzkvgr1.
      if gv_return1 = c_selected.
        continue.
      endif.
*End   of Defect 1177


      move-corresponding wa_904 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A904
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A902
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A902
*----------------------------------------------------------------------*
form f_read_record_a902 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.

  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi, lv_kbetr.
      split  wa_string-string at c_tab into
             wa_902-kappl
             wa_902-kschl
             wa_902-vkorg
             wa_902-vtweg
             wa_902-zzkvgr2
             wa_902-matnr
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.


      wa_902-kbetr = lv_kbetr.
      wa_902-konwa = lv_konwa.
      wa_902-kpein = lv_kpein.
      wa_902-kmein = lv_kmein.


      perform f_date_convert using gv_datab
                             changing wa_902-datab.
      perform f_check_date   using text-024 wa_902-datab.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi
                             changing wa_902-datbi.
      perform f_check_date   using text-025 wa_902-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_legacy_material using wa_902-matnr.

      move-corresponding wa_902 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A902
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A905
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A905
*----------------------------------------------------------------------*
form f_read_record_a905 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.

  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi , lv_kbetr.
      split  wa_string-string at c_tab into
             wa_905-kappl
             wa_905-kschl
             wa_905-vkorg
             wa_905-vtweg
             wa_905-zzkvgr2
             wa_905-prod
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.



      wa_905-kbetr = lv_kbetr.
      wa_905-konwa = lv_konwa.
      wa_905-kpein = lv_kpein.
      wa_905-kmein = lv_kmein.


      perform f_date_convert using gv_datab
                             changing wa_905-datab.
      perform f_check_date   using text-024 wa_905-datab.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi
                             changing wa_905-datbi.
      perform f_check_date   using text-025 wa_905-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.
      move-corresponding wa_905 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A905
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A004
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A004
*----------------------------------------------------------------------*
form f_read_record_a004 .
  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.

  loop at i_string into wa_string.
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi , lv_kbetr.
      split  wa_string-string at c_tab into
             wa_004-kappl
             wa_004-kschl
             wa_004-vkorg
             wa_004-vtweg
             wa_004-matnr
             gv_datab
             gv_datbi
             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.

      wa_004-kbetr = lv_kbetr.
      wa_004-konwa = lv_konwa.
      wa_004-kpein = lv_kpein.
      wa_004-kmein = lv_kmein.


      perform f_date_convert using gv_datab   changing wa_004-datab.
      perform f_check_date   using text-024 wa_004-datab.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.

      perform f_date_convert using gv_datbi changing wa_004-datbi.
      perform f_check_date   using text-025 wa_004-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
        continue.
      endif.
      perform f_legacy_material using wa_004-matnr.
      move-corresponding wa_004 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A004
*&---------------------------------------------------------------------*
*&      Form  F_GET_TABLE_NAME
*&---------------------------------------------------------------------*
*    get condition table name from file name to be uploaded
*----------------------------------------------------------------------*
form f_get_table_name .

*get condition table name from file name
*last 3 characters from .txt extension
  clear : gv_fname , gv_extn1 , gv_length , gv_table.
  split gv_filename at '.' into gv_fname gv_extn1.
  gv_length = strlen( gv_fname ).
  gv_length = gv_length - 3.
  gv_table  = gv_fname+gv_length(3).


endform.                    " F_GET_TABLE_NAME
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_logical_to_physical  using    fp_p_alog
                            changing fp_gv_modify.

  data:   li_input   type zdev_t_file_list_in,
          lwa_input  type zdev_file_list_in,
          li_output  type zdev_t_file_list_out,
          lwa_output type zdev_file_list_out,
          li_error   type zdev_t_file_list_error.

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  append lwa_input to li_input.
  clear lwa_input.

* Retrieving all files within the directory
  call function 'ZDEV_DIRECTORY_FILE_LIST'
    exporting
      im_identifier      = c_true
      im_input           = li_input
    importing
      ex_output          = li_output
      ex_error           = li_error
    exceptions
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      others             = 4.

  if sy-subrc <> 0.
    message i020.
    leave list-processing.
  endif.

  if sy-subrc is initial and
     li_error is initial.

*   Getting the file path
    read table li_output into lwa_output index 1.
    if sy-subrc is initial.
      concatenate lwa_output-physical_path
      lwa_output-filename
      into fp_gv_modify.
    endif.
  else.
*   Logical file path & could not be read for input files.
    message i037 with fp_p_alog.
    leave list-processing.
  endif.

* If Header file could not be retrieved, then issuing an error message
  if fp_gv_modify is initial.
    message i103 with fp_p_alog.
    leave list-processing.
  endif.



endform.                    " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_VERIFY_DAT
*&---------------------------------------------------------------------*
* Check condition type , sales organization and distribution channel
*----------------------------------------------------------------------*
form f_verify_date .


  field-symbols : <lfs_mvke> type ty_mvke,
                  <lfs_kna1> type ty_kna1.

  clear:  wa_t685, gv_error_check.
  read table i_t685 into wa_t685 with key kschl = wa_leg_tab-kschl binary search.
  if sy-subrc <> 0.
    gv_error_check = 'X'.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-026. "Invalid Condition Type
    concatenate
             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  into gv_mkey separated by space.

    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    append  wa_leg_tab to i_leg_tab_err.
    return.
  endif.


  clear wa_tvko.
  read table i_tvko into wa_tvko with key vkorg = wa_leg_tab-vkorg binary search.
  if sy-subrc <> 0.
    gv_error_check = 'X'.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-027. "Invalid Sales Organization
    concatenate

             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  into gv_mkey separated by space.

    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    append  wa_leg_tab to i_leg_tab_err.
    return.
  endif.


  clear wa_tvtw.
  read table i_tvtw into wa_tvtw with key vtweg = wa_leg_tab-vtweg binary search.
  if sy-subrc <> 0.
    gv_error_check = 'X'.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-028."Invalid Distribution Channe
    concatenate
             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  into gv_mkey separated by space.

    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    append  wa_leg_tab to i_leg_tab_err.
    return.
  endif.


  if gv_table = c_005 or
     gv_table = c_901 or
     gv_table = c_902 or
     gv_table = c_004.

    read table i_mvke assigning <lfs_mvke> with key matnr = wa_leg_tab-matnr
                                                     vkorg = wa_leg_tab-vkorg
                                                     vtweg = wa_leg_tab-vtweg
                                                     binary search.
    if sy-subrc <> 0.

      clear wa_report.
      wa_report-msgtyp = c_error.
      concatenate text-034 ':' wa_leg_tab-matnr ','
                               wa_leg_tab-vkorg ','
                               wa_leg_tab-vtweg
      into              wa_report-msgtxt  .

      concatenate   wa_leg_tab-kappl
                    wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-matnr
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    wa_leg_tab-prod
                    wa_leg_tab-zzkvgr1
                    wa_leg_tab-zzkvgr2
                    into gv_mkey separated by space.
      wa_report-key    = gv_mkey.
      append wa_report to i_report.
      clear wa_report.
      gv_error = gv_error + 1.
      gv_skip   = gv_skip + 1.
      append  wa_leg_tab to i_leg_tab_err.
      gv_error_check = 'X'.
      return.
    endif.
  endif.



  if gv_table = c_005 or
     gv_table = c_903.

    read table i_kna1 assigning <lfs_kna1> with key    kunnr  = wa_leg_tab-kunnr
                                                       binary search.
    if sy-subrc <> 0.
      clear wa_report.
      wa_report-msgtyp = c_error.
      concatenate text-036 ':' wa_leg_tab-kunnr
      into              wa_report-msgtxt  .

      concatenate   wa_leg_tab-kappl
                    wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-matnr
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    wa_leg_tab-prod
                    wa_leg_tab-zzkvgr1
                    wa_leg_tab-zzkvgr2
                    into gv_mkey separated by space.
      wa_report-key    = gv_mkey.
      append wa_report to i_report.
      clear wa_report.
      gv_error = gv_error + 1.
      gv_skip   = gv_skip + 1.
      append  wa_leg_tab to i_leg_tab_err.
      gv_error_check = 'X'.
      return.
    endif.
  endif.


  if wa_leg_tab-datab > wa_leg_tab-datbi.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-037.
    concatenate   wa_leg_tab-kappl
                  wa_leg_tab-kschl
                  wa_leg_tab-vkorg
                  wa_leg_tab-vtweg
                  wa_leg_tab-kunnr
                  wa_leg_tab-matnr
                  wa_leg_tab-datab
                  wa_leg_tab-datbi
                  wa_leg_tab-prod
                  wa_leg_tab-zzkvgr1
                  wa_leg_tab-zzkvgr2
                  into gv_mkey separated by space.
    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    gv_skip   = gv_skip + 1.
    append  wa_leg_tab to i_leg_tab_err.
    gv_error_check = 'X'.
    return.
  endif.
endform.                    " F_VERIFY_DATE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY_REPORT1
*&---------------------------------------------------------------------*
*       Display ALV report
*----------------------------------------------------------------------*
*      -->P_I_REPORT[]  text
*      -->P_GV_FILE  text
*      -->P_GV_MODE  text
*      -->P_GV_NO_SUCCESS  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
form f_display_summary_report1 using fp_i_report      type ty_t_report_p
                                    fp_gv_filename_d type localfile
                                    fp_gv_mode       type char50
                                    fp_no_success    type int4
                                    fp_no_failed     type int4.
* Local Data declaration
  types: begin of ty_report_b,
          msgtyp type char1,    "Error Type
          msgtxt type char256,  "Error Text
          key    type char256,  "Error Key
         end of ty_report_b.

  constants: c_hline type char100            " Dotted Line
             value
'-----------------------------------------------------------',
             c_slash type char1 value '/'. "slash

  data: li_report      type standard table of ty_report_b
                                                     initial size 0,
        lv_uzeit       type char20,                          "Time
        lv_datum       type char20,                          "Date
        lv_total       type i,                               "Total
        lv_rate        type i,                               "Rate
        lv_rate_c      type char5,                           "Rate text
        lv_alv         type ref to cl_salv_table,            "ALV Inst.
        lv_ex_msg      type ref to cx_salv_msg,              "Message
        lv_ex_notfound type ref to cx_salv_not_found,        "Exception
        lv_grid        type ref to cl_salv_form_layout_grid, "Grid
        lv_gridx       type ref to cl_salv_form_layout_grid, "Grid X
        lv_column      type ref to cl_salv_column_table,     "Column
        lv_columns     type ref to cl_salv_columns_table,    "Column X
        lv_func        type ref to cl_salv_functions_list,   "Toolbar
        lv_archive_1   type localfile,      "Archieve File Path
        lv_session_1   type apq_grpn,       "BDC Session Name
        lv_session_2   type apq_grpn,       "BDC Session Name
        lv_session_3   type apq_grpn,       "BDC Session Name
        lv_session(90) type c,              "All session names
        lv_row         type i,              "Row number
        lv_width_msg   type outputlen,      "Column Width
        lv_width_key   type outputlen,      "Column Width
        li_fieldcat    type slis_t_fieldcat_alv, "Field Catalog
        li_events      type slis_t_event,"alv events
        lwa_events     type slis_alv_event,"alv ebetns
        li_report_b    type standard table of ty_report_b initial size 0, " report table
        lwa_report_b   type ty_report_b."report workarea

  field-symbols: <fs> type ty_report_p.

* Getting the archieve file path from Global Variables
  lv_archive_1 = gv_archive_gl_1.

* Importing the First Session Names
  lv_session_1 = gv_session_gl_1.

* Importing the Second Session Names
  lv_session_2 = gv_session_gl_2.

* Importing the Third Session Names
  lv_session_3 = gv_session_gl_3.

* Forming the BDC session name
  if lv_session_1 is not initial.
    lv_session = lv_session_1.
  endif.

  if lv_session_2 is not initial.
    if lv_session is not initial.
      concatenate lv_session c_slash lv_session_2
      into lv_session separated by space.
    else.
      lv_session = lv_session_2.
    endif.
  endif.

  if lv_session_3 is not initial.
    if lv_session is not initial.
      concatenate lv_session c_slash lv_session_3
      into lv_session separated by space.
    else.
      lv_session = lv_session_3.
    endif.
  endif.

  if lv_session is not initial.
    concatenate lv_session text-x32 into lv_session
    separated by space.
  endif.

  loop at fp_i_report assigning <fs>.
    lwa_report_b-msgtyp = <fs>-msgtyp.
    lwa_report_b-msgtxt = <fs>-msgtxt.
    lwa_report_b-key = <fs>-key.
    append lwa_report_b to li_report.
    clear lwa_report_b.
  endloop.
*
*  li_report[] = fp_i_report[].

  write sy-uzeit to lv_uzeit.
  write sy-datum to lv_datum.
  concatenate lv_datum lv_uzeit into lv_datum separated by space.

  lv_total = fp_no_success + fp_no_failed.
  if lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  endif.

  write lv_rate to lv_rate_c.
  condense lv_rate_c.
  concatenate lv_rate_c c_percentage into lv_rate_c separated by space.

* For ONLINE run, ALV Grid Display
  if sy-batch is initial.

    try.
        call method cl_salv_table=>factory
          importing
            r_salv_table = lv_alv
          changing
            t_table      = li_report.
      catch cx_salv_msg into lv_ex_msg.
        message lv_ex_msg type 'E'.
      catch  cx_salv_not_found into lv_ex_notfound.
        message lv_ex_notfound type 'E'.
    endtry.

    create object lv_grid.
    lv_row = 1.
    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = text-x01
                                        tooltip = text-x02 ).

    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
* File Read
    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x02 tooltip = text-x02 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_filename_d ).

    lv_row = lv_row + 1.
* File Archived.
    if lv_archive_1 is not initial.
      lv_gridx->create_label( row = lv_row column = 1
                              text = text-x28 tooltip = text-x28 ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = ':' ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_archive_1 ).
      lv_row = lv_row + 1.
    endif.

    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x03 tooltip = text-x03 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-mandt ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x04 tooltip = text-x04 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-uname ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x05 tooltip = text-x05 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x06 tooltip = text-x06 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_mode ).
    lv_row = lv_row + 1.

    if lv_session is not initial.
      lv_gridx->create_label( row = lv_row column = 1
                             text = text-x29 tooltip = text-x29 ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = ':' ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_session ).
      lv_row = lv_row + 1.
    endif.

    lv_gridx->add_row( ).

    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x08 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_total ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x09 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_success ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x10 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_failed ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x11 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_rate_c ).

    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).

    call method lv_alv->set_top_of_list( lv_grid ).

    call method lv_alv->get_columns
      receiving
        value = lv_columns.

    try.
        lv_column ?= lv_columns->get_column( 'MSGTYP' ).
      catch  cx_salv_not_found into lv_ex_notfound.
        message lv_ex_notfound type 'E'.
    endtry.
    lv_column->set_short_text( text-x12 ).
    lv_column->set_medium_text( text-x12 ).
    lv_column->set_long_text( text-x12 ).
*   lv_column->set_output_length( 20 ).
    lv_columns->set_optimize( 'X' ).

    try.
        lv_column ?= lv_columns->get_column( 'MSGTXT' ).
      catch  cx_salv_not_found into lv_ex_notfound.
        message lv_ex_notfound type 'E'.
    endtry.
    lv_column->set_short_text( text-x13 ).
    lv_column->set_medium_text( text-x13 ).
    lv_column->set_long_text( text-x13 ).
    lv_columns->set_optimize( 'X' ).

    try.
        lv_column ?= lv_columns->get_column( 'KEY' ).
      catch  cx_salv_not_found into lv_ex_notfound.
        message lv_ex_notfound type 'E'.
    endtry.
    lv_column->set_short_text( text-x14 ).
    lv_column->set_medium_text( text-x14 ).
    lv_column->set_long_text( text-x14 ).
    lv_columns->set_optimize( 'X' ).

* Function Tool bars
    lv_func = lv_alv->get_functions( ).
    lv_func->set_all( ).

* Displaying the report
    call method lv_alv->display( ).

* For Background Run - ALV List
  else.
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.

* START CHANGE Defect 264
* Increased Variables size to INT4 from INT2
*   gv_total = lv_total.
*   gv_no_success = fp_no_success.
*   gv_no_failed = fp_no_failed.
    gv_total2      = lv_total.
    gv_no_success2 = fp_no_success.
    gv_no_failed2  = fp_no_failed.
* END CHANGE Defect 264
    gv_rate_c = lv_rate_c.
    loop at fp_i_report assigning <fs>.
      lwa_report_b-msgtyp = <fs>-msgtyp.
      lwa_report_b-msgtxt = <fs>-msgtxt.
      lwa_report_b-key = <fs>-key.
*     Getting the maximum length of columns MSGTXT.
      if lv_width_msg   lt strlen( <fs>-msgtxt ).
        lv_width_msg = strlen( <fs>-msgtxt ).
      endif.
*     Getting the maximum length of column KEY.
      if lv_width_key   lt strlen( <fs>-key ).
        lv_width_key = strlen( <fs>-key ).
      endif.
      append lwa_report_b to li_report_b.
      clear lwa_report_b.
    endloop.

    if lv_width_key lt 150.
      lv_width_key = 150.
    endif.

*   Preparing Field Catalog.
*   Message Type
    perform f_fill_fieldcat using 'MSGTYP'
                                  'LI_REPORT_B'
                                  text-x12
                                  7
                          changing li_fieldcat[].
*   Message Text
    perform f_fill_fieldcat using 'MSGTXT'
                                  'LI_REPORT_B'
                                  text-x13
                                  lv_width_msg
                          changing li_fieldcat[].
*   Message Key
    perform f_fill_fieldcat using 'KEY'
                                  'LI_REPORT_B'
                                  text-x14
                                  lv_width_key
                          changing li_fieldcat[].
*   Top of page subroutine
    lwa_events-name = 'TOP_OF_PAGE'.
    lwa_events-form = 'F_TOP_OF_PAGE1'.
    append lwa_events to li_events.
    clear lwa_events.
*   ALV List Display for Background Run
    call function 'REUSE_ALV_LIST_DISPLAY'
      exporting
        i_callback_program = sy-repid
        it_fieldcat        = li_fieldcat
        it_events          = li_events
      tables
        t_outtab           = li_report_b
      exceptions
        program_error      = 1
        others             = 2.
    if sy-subrc <> 0.
      message e002(zca_msg).
    endif.
  endif.


endform.                    " F_DISPLAY_SUMMARY_REPORT1
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether the file name has been entered or not
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  if rb_pres is not initial and
     p_phdr is initial.
    message i000
    with 'Presentation server file has not been entered'(002).
    leave list-processing.
  endif.

* For Application Server
  if rb_app is not initial.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    if rb_aphy is not initial and
       p_ahdr is initial.
      message i000
      with 'Application server file has not been entered'(019).
      leave list-processing.
    endif.



* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    if rb_alog is not initial and
       p_alog is initial.
      message i000
      with 'Logical File Path has not been entered'(020).
      leave list-processing.
    endif.
  endif.


endform.                    " F_CHECK_INPUT


*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE1
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form f_top_of_page1.
* Horizontal Line.
  constants: c_hline type char50            " Dotted Line
             value
'--------------------------------------------------',
             c_colon type char1 value ':'.

* Run Information
  write: / text-x01.
* Horizontal Line
  write: / c_hline.
* File Read
  write: / text-x02, 50(1) c_colon, 52 gv_filename_d.
  if gv_filename_d_arch is not initial.
* File Archived
    write: / text-x28, 50(1) c_colon, 52 gv_filename_d_arch.
  endif.
* Client
  write: / text-x03, 50(1) c_colon, 52 sy-mandt.
* Run By / User Id
  write: / text-x04, 50(1) c_colon, 52 sy-uname.
* Date / Time
  write: / text-x05, 50(1) c_colon, 52 sy-datum, 63 sy-uzeit.
* Execution Mode
  write: / text-x06, 50(1) c_colon, 52 gv_mode_b.
  if gv_session is not initial.
* BDC Session Details
    write: / text-x29, 50(1) c_colon, 52 gv_session.
  endif.
* Horizontal Line
  write: / c_hline.
* Total number of records in the given file
  write: / text-x08, 50(1) c_colon, 52 gv_total2 left-justified.
* Number of Success records
  write: / text-x09, 50(1) c_colon, 52 gv_no_success2 left-justified.
* Number of Error records
  write: / text-x10, 50(1) c_colon, 52 gv_no_failed2 left-justified.
* Success Rate
  write: / text-x11, 50(1) c_colon, 52 gv_rate_c left-justified.
* Horizontal Line
  write: / c_hline.
endform.                    " F_TOP_OF_PAGE1
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BUYGRP
*&---------------------------------------------------------------------*
* Defect 1025: Check for Buying Group. If no Buying Group is passed
* Set Record as Error record
*----------------------------------------------------------------------*
form f_check_buygrp  using    fp_text_038
                              fp_wa_901_zzkvgr1.

  if fp_wa_901_zzkvgr1 is initial.
    clear wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = fp_text_038.
    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    gv_skip  = gv_skip + 1.
    append  wa_leg_tab to i_leg_tab_err.
    gv_return1 = c_selected.
  endif.

endform.                    " F_CHECK_BUYGRP
*&---------------------------------------------------------------------*
*&      Form  F_VALID_BUYGRP
*&---------------------------------------------------------------------*
* Defect 1177: Check for valid Buying Group in table TVV1.
*-----------------------------*----------------------------------------*
form f_valid_buygrp  using    fp_text_039
                              fp_wa_zzkvgr1.

  field-symbols : <lfs_tvv1> type ty_tvv1.

  read table i_tvv1 assigning <lfs_tvv1> with key kvgr1 = fp_wa_zzkvgr1 binary search.
  if sy-subrc <> 0.
    clear wa_report.
    wa_report-msgtyp = c_error.
    concatenate fp_text_039 fp_wa_zzkvgr1 into
    wa_report-msgtxt.
    wa_report-key    = gv_mkey.
    append wa_report to i_report.
    clear wa_report.
    gv_error = gv_error + 1.
    gv_skip  = gv_skip + 1.
    append  wa_leg_tab to i_leg_tab_err.
    gv_return1 = c_selected.
  endif.
endform.                    " F_VALID_BUYGRP
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD_A911
*&---------------------------------------------------------------------*
*    populate internal table i_leg_tab for fields required for
*    condition table A911
*----------------------------------------------------------------------*
form F_READ_RECORD_A911 .


  data : lv_kbetr(16) type c.
  data : lv_konwa(5) type c.
  data : lv_kpein(5) type c.
  data : lv_kmein(3) type c.


  loop at i_string into wa_string.
*skip header record
    if sy-tabix > 1.
      clear: gv_datab, gv_datbi, lv_kbetr.
      split  wa_string-string at c_tab into

             wa_911-kappl
             wa_911-kschl
             wa_911-vkorg
             wa_911-vtweg
             wa_911-kunnr
             wa_911-matnr

             gv_datab
             gv_datbi

             lv_kbetr
             lv_konwa
             lv_kpein
             lv_kmein.



      wa_911-kbetr = lv_kbetr.
      wa_911-konwa = lv_konwa.
      wa_911-kpein = lv_kpein.
      wa_911-kmein = lv_kmein.





*convert from date from MM.DD.YYYY to YYYYMM DD
      perform f_date_convert using gv_datab
                             changing wa_911-datab.
*Check valid date
      perform f_check_date   using text-024 wa_911-datab.
*                             CHANGING gv_return1.
*Error skip record
      if gv_return1 = c_selected.
        continue.
      endif.

*convert to date from MM.DD.YYYY to YYYYMM DD
      perform f_date_convert using gv_datbi
                             changing wa_911-datbi.
*Check valid date
      perform f_check_date   using text-025 wa_911-datbi.
*                             CHANGING gv_return1.
      if gv_return1 = c_selected.
*Error skip record
        continue.
      endif.

*populate material mapping table
      perform f_legacy_material using wa_911-matnr.
*convert customer to ECC format
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = wa_911-kunnr
        importing
          output = wa_911-kunnr.
      move-corresponding wa_911 to wa_leg_tab.
      append wa_leg_tab to i_leg_tab.
    endif.
  endloop.
endform.                    " F_READ_RECORD_A911
