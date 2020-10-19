*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0050O_REBATE_CONVERSION                            *
* TITLE      :  OTC_CDD_0050_Convert_Rebate                            *
* DEVELOPER  :  SATEERTH DAS                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0050_Convert_Recipe                              *
*----------------------------------------------------------------------*
* DESCRIPTION: Uploads a user-generated spreadsheet (tab delimited)
*              file for a Call Transaction of VBO1 (create rebate).
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2012 SDAS     E1DK903273 INITIAL DEVELOPMENT                  *
* 31-Oct-2012 SPURI    E1DK905593 Defect 1247 : Incorrect
*                                 number of Agreements created for a
*                                 unique combination of Customer  and
*                                 GPO number.  Code Change : Removed
*                                 AT NEW statement  instead declared a
*                                 local variable to hold previous value
*                                 of GPO and customer.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*

form f_modify_screen .
  loop at screen .
*   Presentation Server Option is NOT chosen
    if rb_pres ne c_true.
*     Hiding Presentation Server file paths with modifidd MI3.
      if screen-group1 = c_groupmi3.
        screen-active = c_zero.
        modify screen.
      endif.
*   Presentation Server Option IS chosen
    else.  "IF rb_pres EQ c_true.
*     Disaplying Presentation Server file paths with modifidd MI3.
      if screen-group1 = c_groupmi3.
        screen-active = c_one.
        modify screen.
      endif.
    endif.
*   Application Server Option is NOT chosen
    if rb_app ne c_true.
*     Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      if screen-group1 = c_groupmi2
         or screen-group1 = c_groupmi5
         or screen-group1 = c_groupmi7.
        screen-active = c_zero.
        modify screen.
      endif.
*   Application Server Option IS chosen
    else.  "IF rb_app EQ c_true.
*     If Application Server Physical File Radio Button is chosen
      if rb_aphy eq c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        if screen-group1 = c_groupmi2.
          screen-active = c_one.
          modify screen.
        endif.
*       Hiding Logical Filaename input with modifid MI7
        if screen-group1 = c_groupmi7.
          screen-active = c_zero.
          modify screen.
        endif.
*     If Application Server Logical File Radio Button is chosen
      else.   "IF rb_alog EQ c_true.
*       Hiding Application Server - Physical paths with modifidd MI2
        if screen-group1 = c_groupmi2.
          screen-active = c_zero.
          modify screen.
        endif.
*       Displaying Logical Filaename input with modifid MI7
        if screen-group1 = c_groupmi7.
          screen-active = c_one.
          modify screen.
        endif.
      endif.
    endif.
  endloop.
endform.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*       Checking whetehr the file has .TXT extension.
*----------------------------------------------------------------------*
*      -->FP_P_FILE  Input file path
*----------------------------------------------------------------------*
form f_check_extension  using fp_p_file type localfile.

  if fp_p_file is not initial.
    clear gv_extn.
*   Getting the file extension
    perform f_file_extn_check using fp_p_file
                           changing gv_extn.
    if gv_extn <> c_text.
      message e008.
    endif.
  endif.
endform.                    "f_check_extension

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
form f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  if rb_pres is not initial and
     p_pfile is initial.
    message i032.
    leave list-processing.
  endif.

* For Application Server
  if rb_app is not initial.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    if rb_aphy is not initial and
       p_afile is initial.
      message i033.
      leave list-processing.
    endif.

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    if rb_alog is not initial and
       p_alog is initial.
      message i034.
      leave list-processing.
    endif.
  endif.


endform.                    " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_MODE  text
*----------------------------------------------------------------------*
form f_set_mode  changing fp_gv_mode.

* Choosing the Mode
  if rb_post = c_true.
    fp_gv_mode = 'Post Run'(005).
  else.
    fp_gv_mode = 'Test Run'(006).
  endif.

endform.                    " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_upload_pres  using    fp_p_file.

* Local Data Declaration
  data: lv_filename type string.  "File Name

  lv_filename = fp_p_file.

* Uploading the file from Presentation Server
  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename                = lv_filename
      filetype                = c_filetype
      has_field_separator     = c_true
    changing
      data_tab                = i_final[]
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
  if sy-subrc is not initial.
    message i023 with lv_filename.
    leave list-processing.
  else.
*   Deleting the Header Line
    delete i_final index 1.
  endif.


endform.                    " F_UPLOAD_PRES

*&---------------------------------------------------------------------*
*&      Form  F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FILE  text
*----------------------------------------------------------------------*
form f_get_apps_server  changing fp_gv_file   type localfile.

* Application file can be uploaded in 2 ways -
* Either from Logical file path or from direct application file
  if rb_app is not initial.
*   If Logical File option is selected.
    if rb_alog is not initial.
*     Retriving physical file paths from logical file name
      perform f_logical_to_physical using p_alog
                                 changing fp_gv_file.
    else.
      fp_gv_file = p_afile.
    endif.
*   Uploading the files from Application Server
    perform f_upload_apps using fp_gv_file .

  endif.

endform.                    " F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*&      Form  SUB_CLEAR_VARIABLES
*&---------------------------------------------------------------------*
form sub_clear_variables .

  clear : i_final2  , wa_final .

endform.                    " SUB_CLEAR_VARIABLES
*&---------------------------------------------------------------------*
*&      Form  SUB_FILL_DATA
*&---------------------------------------------------------------------*
form sub_fill_data .

  data : lv_kunnr type kunnr .

  i_final2[] = i_final[] .

  loop at i_final into wa_final .

    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = wa_final-bonem
      importing
        output = wa_final-bonem.


    select single kunnr from kna1
            into lv_kunnr
            where kunnr = wa_final-bonem .

    if sy-subrc <> 0.
      wa_final3 = wa_final .
      append wa_final3 to i_final3 .
    endif.
  endloop .

  if i_final3[] is not initial and rb_vrfy is not initial .
    write : text-007 .
    loop at i_final3 into wa_final3 .
      write : / wa_final3-bonem .
    endloop .
  else.
    write : text-008 .
  endif .




endform.                    " SUB_FILL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BDC_OPEN_GROUP
*&---------------------------------------------------------------------*
form f_bdc_open_group .

  data: lv_sess type apqi-groupid.
* get the value in local variable
  lv_sess = c_session.
* Run function module to open BDC session
  call function 'BDC_OPEN_GROUP'
    exporting
      client              = sy-mandt
      group               = lv_sess
      user                = sy-uname
      keep                = c_x
    exceptions
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10.

  if sy-subrc ne 0.
    message i028.
    leave list-processing.

  endif.

endform.                    " F_BDC_OPEN_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_BDC_INSERT_DATA
*&---------------------------------------------------------------------*
form f_bdc_insert_data .

  data : lv_val    type num2  value '01',
         lv_val1   type num2  value '02',
         lv_val2   type num2  value '13',
         lv_kbrue  type char20,
         lv_kbetr  type char20,
         lv_matnr  type char20,
         lv_old_kdkgr type char3,  " Prev GPO ++Defect 1247
         lv_old_bonem type char10. " Prev GPO ++Defect 1247

  constants : lc_kbrue  type char20    value 'KONP-KBRUE(',
              lc_kbetr  type char20    value 'KONP-KBETR(',
              lc_matnr  type char20    value 'KOMG-MATNR(',
              lc_syn    type char3     value ')'.



  sort i_final ASCENDING by bonem ASCENDING kdkgr.
  loop at i_final into wa_final.
    wa_final1 = wa_final .
*Start Of Defect 1247
*   AT NEW KDKGR.
    if lv_old_kdkgr <> wa_final1-kdkgr or
       lv_old_bonem <> wa_final1-bonem.
*End of defect 1247
      perform f_bdcc_dynpro     using 'SAPMV13A'     '0400'.
      perform f_bdc_field       using 'BDC_CURSOR'   'RV13A-BOART_BO'.
      perform f_bdc_field       using 'BDC_OKCODE'   '=ORGA'.
      perform f_bdc_field       using 'RV13A-BOART_BO '  wa_final1-boart.

      perform f_bdcc_dynpro     using 'SAPMV13A'     '0404'.
      perform f_bdc_field       using 'BDC_CURSOR'   'KONA-SPART'.
      perform f_bdc_field       using 'BDC_OKCODE'   '=ORUE'.
      perform f_bdc_field       using 'KONA-VKORG '  wa_final1-vkorg.
      perform f_bdc_field       using 'KONA-VTWEG '  wa_final1-vtweg.
      perform f_bdc_field       using 'KONA-SPART '  wa_final1-spart.

      perform f_bdcc_dynpro     using 'SAPMV13A'     '0410'.
      perform f_bdc_field       using 'BDC_CURSOR'   'KONA-BONEM'.
      perform f_bdc_field       using 'BDC_OKCODE'   '=BOKL'.
      perform f_bdc_field       using 'KONA-BOTEXT '  wa_final1-botext.
      perform f_bdc_field       using 'KONA-BONEM '  wa_final1-bonem.
      perform f_bdc_field       using 'KONA-WAERS '  wa_final1-waers.
      perform f_bdc_field       using 'KONA-DATAB '  wa_final1-datab.
      perform f_bdc_field       using 'KONA-DATBI '  wa_final1-datbi.
      perform f_bdc_field       using 'KONA-ABSPZ '  wa_final1-abspz.

      if wa_final1-boart = c_zidn .

        perform f_bdcc_dynpro     using 'SAPMV13A'     '6902'.
        perform f_bdc_field       using 'BDC_CURSOR'   'KOMG-MATNR(01)'.
        perform f_bdc_field       using 'BDC_OKCODE'   '/00'.
        perform f_bdc_field       using 'KOMG-VKORG '  wa_final1-vkorg.
        perform f_bdc_field       using 'KOMG-VTWEG '  wa_final1-vtweg.
        perform f_bdc_field       using 'KOMG-ZZKVGR2 '  wa_final1-kdkgr.
        perform f_bdc_field       using 'KONA-DATAB '  wa_final1-datab.
        perform f_bdc_field       using 'KONA-DATBI '  wa_final1-datbi.

        loop at i_final2 into wa_final2 where boart = wa_final-boart
                                        and   bonem = wa_final-bonem
                                        and   kdkgr = wa_final-kdkgr .

          if lv_val = lv_val2.
            perform f_bdcc_dynpro  using 'SAPMV13A'     '6902'.
            perform f_bdc_field    using 'BDC_OKCODE' '=P+'.
            clear lv_val.
            lv_val = lv_val1.
          endif.

          concatenate lc_kbetr lv_val lc_syn into lv_kbetr.
          concatenate lc_kbrue lv_val lc_syn into lv_kbrue.
          concatenate lc_matnr lv_val lc_syn into lv_matnr.


          perform f_bdc_field       using lv_kbetr  wa_final2-kbetr.
          perform f_bdc_field       using lv_kbrue  wa_final2-kbrue.
          perform f_bdc_field       using lv_matnr  wa_final2-bomat.

          lv_val = lv_val + 1.
          clear wa_final2 .
        endloop .
*      Clear : lv_count, lv_val1, lv_val2.

        perform f_bdcc_dynpro     using 'SAPMV13A'     '6902'.
        perform f_bdc_field       using 'BDC_CURSOR'   'KOMG-VKORG'.
        perform f_bdc_field       using 'BDC_OKCODE'   '=SICH'.

      endif.

      if wa_final1-boart = c_zgpo .

        perform f_bdcc_dynpro     using 'SAPMV13A'      '6901'.
        perform f_bdc_field       using 'BDC_CURSOR'    'KOMG-MATNR(01)'.
        perform f_bdc_field       using 'BDC_OKCODE'    '/00'.
        perform f_bdc_field       using 'KOMG-VKORG '    wa_final1-vkorg.
        perform f_bdc_field       using 'KOMG-VTWEG '    wa_final1-vtweg.
        perform f_bdc_field       using 'KOMG-ZZKVGR1 '  wa_final1-kdkgr.
        perform f_bdc_field       using 'KONA-DATAB '    wa_final1-datab.
        perform f_bdc_field       using 'KONA-DATBI '    wa_final1-datbi.

        loop at i_final2 into wa_final2 where boart = wa_final-boart
                                        and   bonem = wa_final-bonem
                                        and   kdkgr = wa_final-kdkgr .

          if lv_val = lv_val2.
            perform f_bdcc_dynpro  using 'SAPMV13A'     '6901'.
            perform f_bdc_field    using 'BDC_OKCODE'   '=P+'.
            clear lv_val.
            lv_val = lv_val1.
          endif.

          concatenate lc_kbetr lv_val lc_syn into lv_kbetr.
          concatenate lc_kbrue lv_val lc_syn into lv_kbrue.
          concatenate lc_matnr lv_val lc_syn into lv_matnr.


          perform f_bdc_field       using lv_kbetr  wa_final2-kbetr.
          perform f_bdc_field       using lv_kbrue  wa_final2-kbrue.
          perform f_bdc_field       using lv_matnr  wa_final2-bomat.

          lv_val = lv_val + 1.
          clear wa_final2 .
        endloop .
*      Clear : lv_count, lv_val1, lv_val2.
        perform f_bdcc_dynpro      using 'SAPMV13A'     '6901'.
        perform f_bdc_field       using 'BDC_CURSOR'   'KOMG-VKORG'.
        perform f_bdc_field       using 'BDC_OKCODE'   '=SICH'.
      endif.

*   Trnsaction VBO1 is recorded
      perform f_bdc_transaction .
      refresh :i_bdcdata.
*Start of defect 1247
*    ENDAT .
      lv_old_kdkgr = wa_final1-kdkgr.
      lv_old_bonem = wa_final1-bonem.
    endif.
*End of defect 1247
    clear : wa_final , wa_final1 .
  endloop .
endform.                    " F_BDC_INSERT_DATA
*&---------------------------------------------------------------------*
*&      Form  f_bdcC_TRANSACTION
*&---------------------------------------------------------------------*
form f_bdc_transaction  .

  data: lv_tcode type tcode.
  lv_tcode = c_tcode.
* Function Module for Inserting recorded data for transaction C202.
  call function 'BDC_INSERT'
    exporting
      tcode            = lv_tcode
    tables
      dynprotab        = i_bdcdata
    exceptions
      internal_error   = 1
      not_open         = 2
      queue_error      = 3
      tcode_invalid    = 4
      printing_invalid = 5
      posting_invalid  = 6
      others           = 7.
  if sy-subrc <> 0.
    message i026.
    leave list-processing.
  endif.

endform.                    " f_bdcC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CLOSE_GROUP
*&---------------------------------------------------------------------*
form f_bdc_close_group .
*  Function module to close the BDC session
  call function 'BDC_CLOSE_GROUP'
    exceptions
      not_open    = 1
      queue_error = 2
      others      = 3.
  if sy-subrc eq 0.
    message i029 with c_session.
  endif.
  if sy-subrc <> 0.
    message i027.
    leave list-processing.
  endif.

endform.                    " F_BDC_CLOSE_GROUP
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
form f_bdcc_dynpro using fp_program type any
                          fp_dynpro  type any.
  clear wa_bdcdata.
  wa_bdcdata-program  = fp_program.
  wa_bdcdata-dynpro   = fp_dynpro.
  wa_bdcdata-dynbegin = c_x.
  append wa_bdcdata to i_bdcdata.
endform.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
form f_bdc_field using fp_fnam type any
                         fp_fval type any.
  clear wa_bdcdata.
  if fp_fval is not initial.
    wa_bdcdata-fnam = fp_fnam.
    wa_bdcdata-fval = fp_fval.
  endif.
  append wa_bdcdata to i_bdcdata.
endform.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
form f_logical_to_physical  using    fp_p_alog   type pathintern
                            changing fp_gv_file  type localfile.

* Local Data Declaration
  data: li_input   type zdev_t_file_list_in,    "Local Input table
        lwa_final  type zdev_file_list_in,      "Local work area
        li_output  type zdev_t_file_list_out,   "Local Output Table
        lwa_output type zdev_file_list_out,     "Local work area
        li_error   type zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_final-path = fp_p_alog.
  append lwa_final to li_input.
  clear lwa_final.

* Retriving all files within the directory
  call function 'ZDEV_DIRECTORY_FILE_LIST'
    exporting
      im_identifier      = c_lp_ind
      im_input           = li_input
    importing
      ex_output          = li_output
      ex_error           = li_error
    exceptions
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      others             = 4.
  if sy-subrc is initial and
     li_error is initial.
*   Getting the file path
    read table li_output into lwa_output index 1.
    if sy-subrc is initial.
      concatenate lwa_output-physical_path
             lwa_output-filename
             into fp_gv_file.
    endif.
  else.
*   Logical file path & could not be read for input files.
    message i037 with fp_p_alog.
    leave list-processing.
  endif.

* If Input file could not be retrieved, then issue an error message
  if fp_gv_file is initial.
    message i103 with fp_p_alog.
    leave list-processing.
  endif.


endform.                    " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
form f_upload_apps  using    fp_p_file   type localfile .

* Local Variables
  data: lv_input_line type string,         "Input Raw lines
        lwa_final     type ty_final,       "Input work area
        lv_subrc      type sysubrc.        "SY-SUBRC value

* Opening the Dataset for File Read
  open dataset fp_p_file for input in text mode encoding default.
  if sy-subrc is initial.
*   Reading the Header Input File
    while ( lv_subrc eq 0 ).
      read dataset fp_p_file into lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      if lv_subrc is initial.
*       Aligning the values as per the structure
        split lv_input_line at c_tab
        into lwa_final-vkorg     " sales org
             lwa_final-vtweg     " distribution channel
             lwa_final-spart     " Division
             lwa_final-vkbur     " sales Office
             lwa_final-boart     " Agreement type
             lwa_final-abtyp    " Agreement category
             lwa_final-kappl     " Application
             lwa_final-bonem     " rebate recipient
             lwa_final-waers     " Currency
             lwa_final-abrex     " External Description
             lwa_final-ekorg     " Purchasing org
             lwa_final-bolif     " Condition granter
             lwa_final-abspz     " Verification Levels
             lwa_final-bosta     " Agreement Status
             lwa_final-datab     " Valid date
             lwa_final-datbi     " Valid to
             lwa_final-kobog     " Condition type group
             lwa_final-kdkgr     " Condition Type
             lwa_final-botext    " Description
             lwa_final-zlsch     " Payment method
             lwa_final-valtg     " Addition value days
             lwa_final-valdt     " Fixed value date
             lwa_final-zterm     " Terms of Payment
             lwa_final-bukrs     "  Company Code
             lwa_final-kschl     " Condition
             lwa_final-kbetr     " rate
             lwa_final-bomat     " material
             lwa_final-kbrue .   " Accruals

        append lwa_final to i_final.
        clear: lv_input_line,
               lwa_final.
      endif.
    endwhile.
* If File Open fails, then populating the Error Log
  else.
*   Leaving the program if OPEN Dataset fails for data upload
    message i024 with fp_p_file.
    leave list-processing.
  endif.
* Closing the Dataset.
  close dataset fp_p_file.

* Deleting the First Index Line from the table
  delete i_final index 1.

endform.                    " F_UPLOAD_APPS
