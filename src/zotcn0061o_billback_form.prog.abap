*&---------------------------------------------------------------------*
*&  Include           ZOTCN0061O_BILLBACK_FORM
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0061O_BILLBACK_FORM                               *
* TITLE      :  OTC_CDD_0061_Convert 1 year history data for billback  *
*               and commission.
* DEVELOPER  :  Deepa Sharma                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0061_SAP                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Subroutines include for billback and commission history*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-MAY-2012 DSHARMA1 E1DK901626  INITIAL DEVELOPMENT                 *
* 16-Oct-2012 SPURI    E1DK906961  Defect 492 :Skip Header Record from
*                                  Input File                          *
*                                  Defect 628 :Do not Check Customer   *
*                                  Material Number From MARA
* 25-Oct-2012 ADAS1    E1DK906961  Defect 597 : EXPNR fields should not
*                                  be mandatory for loading.
* 02-Nov-2012 SPURI    E1DK906961  Defect 1353: In case no product
*                                  hierarchy is passed from input file
*                                  read it from table MARA for a given
*                                  material
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&    Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*     Modify the selection screen based on radio button selection.
*----------------------------------------------------------------------*
form f_modify_screen.

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
*&      Form  F_HELP_L_PATH_TXT
*&---------------------------------------------------------------------*
*       F4 help for Presentation Server to browse .TXT files
*----------------------------------------------------------------------*
*      <--FP_V_FILENAME  Selected File Path from Presentation Server
*----------------------------------------------------------------------*
form f_help_l_path_txt changing fp_v_filename type localfile.
* Local Data Declaration
  data: li_table  type filetable,
        lwa_table type file_table, "Work area
        lv_filter type string,     "File Type  - Filter for Text files.
        lv_rc     type i.          "Return Code

* .TXT filter type
  lv_filter = cl_gui_frontend_services=>filetype_text.

* F4 help for presentation server file path.
  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      file_filter             = lv_filter  " *.txt file type
    changing
      file_table              = li_table
      rc                      = lv_rc
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.
  if sy-subrc is initial.
*   Returning back the Full File path of selected file from
*   presentation server
    read table li_table into lwa_table index 1.
    if sy-subrc is initial.
      fp_v_filename = lwa_table-filename.
    endif.
  else.
    message i001(zca_msg).  "File browse failed.
  endif.
endform.                    "F_HELP_L_PATH_TXT
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
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
      message e000 with 'Please provide text file'(m00).
    endif.
  endif.
endform.                    " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether file names have entered for chosen option at
*       Run time.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  if rb_pres is not initial and
     p_pfile is initial.
    message i000 with 'Presentation server file has not been entered.'(m01).
    leave list-processing.
  endif.

* For Application Server
  if rb_app is not initial.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    if rb_aphy is not initial and
       p_afile is initial.
      message i000 with 'Application server file has not been entered.'(m02).
      leave list-processing.
    endif.

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    if rb_alog is not initial and
       p_alog is initial.
      message i000 with 'Logical File Path has not been entered.'(m04).
      leave list-processing.
    endif.
  endif.
endform.                    " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       Setting the mode of processing
*       SPACE - for Verify only mode
*       "X"   - for Verify and Post mode
*----------------------------------------------------------------------*
*      <--FP_GV_MODE  Mode of Processing - Text
*----------------------------------------------------------------------*
form f_set_mode  changing fp_gv_mode type char10.
* If Verify and Post is selected, then putting the Flag ON
  if rb_post is not initial.
    fp_gv_mode = 'Post Run'(002).
  elseif rb_vrfy is not initial.
    fp_gv_mode = 'Test Run'(003).
  endif.
endform.                    " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*       Upload input file from Presentation Server
*----------------------------------------------------------------------*
*      -->FP_P_FILE        Input File location
*      <--FP_I_INPUT       Input Data
*----------------------------------------------------------------------*
form f_upload_pres  using    fp_p_file  type localfile
                    changing fp_i_input type ty_t_input.

* Local Data Declaration

  data: li_string       type standard table of string initial size 0,        "Defect#492++
        lv_filename     type string,         "File Name
        lwa_input       type ty_input,       "Local work area
        lv_fkimg        type char17,         "Actual Invoiced Quantity       "Defect#492++
        lv_netwr        type char21,         "Net Value in Document Currency "Defect#492++
        lv_zzcont_price type char21,         "Contract Price                 "Defect#492++
        lv_zzset_qty    type char17,         "Settled Qty                    "Defect#492++
        lv_zzbal_qty    type char17,         "Balanced Qty                   "Defect#492++
        lv_zzset_amnt   type char21.         "Settled Amount                 "Defect#492++

 field-symbols : <lfs_string> type string.                                   "Defect#492++

  lv_filename = fp_p_file.
* Start Of Defect#492
* Uploading the file from Presentation Server
  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename                = lv_filename
      filetype                = c_filetype
*     has_field_separator     = c_true
    changing
      data_tab                = li_string[]
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
    message i000 with 'File could not be read from'(m07) lv_filename.
    leave list-processing.
  else.
    loop at li_string assigning <lfs_string>.
* Skip header record
      if sy-tabix > 1.
*       Aligning the values as per the structure
        split <lfs_string> at c_tab
        into lwa_input-vbeln           "Billing Document
             lwa_input-posnr           "Billing item
             lwa_input-matnr           "Material Number
             lwa_input-vkorg           "Sales Organization
             lwa_input-vtweg           "Distribution Channel
             lwa_input-kunag           "Sold-to party
             lwa_input-kunnr           "Customer Number
             lwa_input-bstkd           "Customer purchase order number
             lwa_input-fkart           "Billing Type
             lwa_input-zzleg_inv_typ   "Legacy Invoice Type
             lwa_input-zzleg_so        "Legacy Sales Order number
             lwa_input-fkdat           "Billing date for billing index and printout
             lwa_input-expnr           "External partner number (in customer system)
             lwa_input-bstdk           "Customer purchase order date
             lwa_input-prodh           "Standard data element PRODH4
             lwa_input-zzcus_mat_no    "Customer Material Number
             lv_fkimg                  "Actual Invoiced Quantity
             lwa_input-zzgln_code      "Legacy GLN Code
             lwa_input-kdgrp           "Customer Group
             lwa_input-kvgr1           "Buying group
             lwa_input-kvgr2           "IDN Code
             lv_netwr                  "Net Value in Document Currency
             lv_zzcont_price           "Contract Price
             lv_zzset_qty              "Settled Qty
             lv_zzbal_qty              "Balanced Qty
             lwa_input-zzref_inv_no    "Reference invoice for old sale
             lwa_input-zzref_inv_date  "Reference invoice for old sale Date
             lwa_input-auart           "Sales Document Type
             lv_zzset_amnt             "Settled Amount
             lwa_input-zzold_new_ind   "Old/New Sale Indicator
             lwa_input-zzlot_number    "Lot Number
             lwa_input-zzpo_date       "Reference FirstOf DropShip PO
             lwa_input-zzprod_family_cd."Product Family Code

        move lv_fkimg        to  lwa_input-fkimg .          "Actual Invoiced Quantity
        move lv_netwr        to  lwa_input-netwr .          "Net Value in Document Currency
        move lv_zzcont_price to  lwa_input-zzcont_price .   "Contract Price
        move lv_zzset_qty    to  lwa_input-zzset_qty .      "Settled Qty
        move lv_zzbal_qty    to  lwa_input-zzbal_qty .      "Balanced Qty
        move lv_zzset_amnt   to  lwa_input-zzset_amnt .     "Settled Amount
*       If the last entry is a Line Feed (i.e. CR_LF), then ignor it.
        if lwa_input-zzprod_family_cd = c_crlf.
          clear lwa_input-zzprod_family_cd.
        elseif lwa_input-zzprod_family_cd ca c_crlf.
*      If the last field does not fills up the full length of
*      field, then the last character will be CR-LF. Replacing the
*      CR-LF from the last field if it contains CR-LF.
          replace all occurrences of c_crlf in lwa_input-zzprod_family_cd
          with space.
*      Removing the space.
          condense lwa_input-zzprod_family_cd.
        endif.
        append lwa_input to fp_i_input.
      endif.
    endloop.
* End Of Defect#492
  endif.
endform.                    " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Retriving physical file paths from logical file name
*----------------------------------------------------------------------*
*      -->FP_P_ALOG    Logical File Name
*      <--FP_GV_FILE   Physical File Path
*----------------------------------------------------------------------*
form f_logical_to_physical  using    fp_p_alog   type pathintern
                            changing fp_gv_file  type localfile.
* Local Data Declaration
  data: li_input   type zdev_t_file_list_in,    "Local Input table
        lwa_input  type zdev_file_list_in,      "Local work area
        li_output  type zdev_t_file_list_out,   "Local Output Table
        lwa_output type zdev_file_list_out,     "Local work area
        li_error   type zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  append lwa_input to li_input.
  clear lwa_input.

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
    message i000 with 'Logical file path could not be read:'(m05) fp_p_alog.
    leave list-processing.
  endif.

* If Input file could not be retrieved, then issuing an error message
  if fp_gv_file is initial.
    message i000 with 'No Input file could be retrieved from Logical path'(m06) fp_p_alog.
    leave list-processing.
  endif.

endform.                    " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*       Uploading Header File from Applicatoin Server.
*----------------------------------------------------------------------*
*      -->FP_P_FILE        Input file path @ Application Server
*      <--FP_I_INPUT       Input Data
*----------------------------------------------------------------------*
form f_upload_apps  using    fp_p_file   type localfile
                    changing fp_i_input  type ty_t_input.
* Local Variables
  data: lv_input_line   type string,         "Input Raw lines
        lv_fkimg        type char17,         "Actual Invoiced Quantity
        lv_netwr        type char21,         "Net Value in Document Currency
        lv_zzcont_price type char21,         "Contract Price
        lv_zzset_qty    type char17,         "Settled Qty
        lv_zzbal_qty    type char17,         "Balanced Qty
        lv_zzset_amnt   type char21,         "Settled Amount
        lwa_input       type ty_input,       "Input work area
        lv_subrc        type sysubrc.        "SY-SUBRC value
* Opening the Dataset for File Read
  open dataset fp_p_file for input in text mode encoding default.
  if sy-subrc is initial.
*   Reading the Header Input File
    while ( lv_subrc eq 0 ).
      read dataset fp_p_file into lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      if lv_subrc is initial.
* Start Of Defect#492
        if sy-index > 1.
*       Aligning the values as per the structure
          split lv_input_line at c_tab
          into lwa_input-vbeln           "Billing Document
               lwa_input-posnr           "Billing item
               lwa_input-matnr           "Material Number
               lwa_input-vkorg           "Sales Organization
               lwa_input-vtweg           "Distribution Channel
               lwa_input-kunag           "Sold-to party
               lwa_input-kunnr           "Customer Number
               lwa_input-bstkd           "Customer purchase order number
               lwa_input-fkart           "Billing Type
               lwa_input-zzleg_inv_typ   "Legacy Invoice Type
               lwa_input-zzleg_so        "Legacy Sales Order number
               lwa_input-fkdat           "Billing date for billing index and printout
               lwa_input-expnr           "External partner number (in customer system)
               lwa_input-bstdk           "Customer purchase order date
               lwa_input-prodh           "Standard data element PRODH4
               lwa_input-zzcus_mat_no    "Customer Material Number
               lv_fkimg                  "Actual Invoiced Quantity
               lwa_input-zzgln_code      "Legacy GLN Code
               lwa_input-kdgrp           "Customer Group
               lwa_input-kvgr1           "Buying group
               lwa_input-kvgr2           "IDN Code
               lv_netwr                  "Net Value in Document Currency
               lv_zzcont_price           "Contract Price
               lv_zzset_qty              "Settled Qty
               lv_zzbal_qty              "Balanced Qty
               lwa_input-zzref_inv_no    "Reference invoice for old sale
               lwa_input-zzref_inv_date  "Reference invoice for old sale Date
               lwa_input-auart           "Sales Document Type
               lv_zzset_amnt             "Settled Amount
               lwa_input-zzold_new_ind   "Old/New Sale Indicator
               lwa_input-zzlot_number    "Lot Number
               lwa_input-zzpo_date       "Reference FirstOf DropShip PO
               lwa_input-zzprod_family_cd."Product Family Code

          move lv_fkimg        to  lwa_input-fkimg .          "Actual Invoiced Quantity
          move lv_netwr        to  lwa_input-netwr .          "Net Value in Document Currency
          move lv_zzcont_price to  lwa_input-zzcont_price .   "Contract Price
          move lv_zzset_qty    to  lwa_input-zzset_qty .      "Settled Qty
          move lv_zzbal_qty    to  lwa_input-zzbal_qty .      "Balanced Qty
          move lv_zzset_amnt   to  lwa_input-zzset_amnt .     "Settled Amount
*       If the last entry is a Line Feed (i.e. CR_LF), then ignor it.
          if lwa_input-zzprod_family_cd = c_crlf.
            clear lwa_input-zzprod_family_cd.
          elseif lwa_input-zzprod_family_cd ca c_crlf.
*         If the last field does not fills up the full length of
*         field, then the last character will be CR-LF. Replacing the
*         CR-LF from the last field if it contains CR-LF.
            replace all occurrences of c_crlf in lwa_input-zzprod_family_cd
            with space.
*         Removing the space.
            condense lwa_input-zzprod_family_cd.
          endif.
          append lwa_input to fp_i_input.
          clear lv_input_line.
        endif.
      endif.
* End Of Defect#492
    endwhile.
* If File Open fails, then populating the Error Log
  else.
*   Leaving the program if OPEN Dataset fails for data upload
    message i000 with 'File could not be read from'(m07) fp_p_file.
    leave list-processing.
  endif.
* Closing the Dataset.
  close dataset fp_p_file.

endform.                    " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_GET_DB_VALUES
*&---------------------------------------------------------------------*
*       Retrieving existing data for validation purpose
*----------------------------------------------------------------------*
*      -->FP_I_INPUT[]    Input Records
*      <--FP_I_MARA[]     Material Records
*      <--FP_I_TVKO[]     Sales Organization Records
*      <--FP_I_TVTW[]     Distribution Channel Records
*      <--FP_I_KNA1[]     Customer Records
*      <--FP_I_T151[]     Customer Group Records
*      <--FP_I_TVV1[]     Customer Group1 Records
*      <--FP_I_TVV2[]     Customer Group2 Records
*----------------------------------------------------------------------*
form f_get_db_values changing fp_i_input    type ty_t_input
                              fp_i_mara     type ty_t_mara
                              fp_i_tvko     type ty_t_tvko
                              fp_i_tvtw     type ty_t_tvtw
                              fp_i_kna1     type ty_t_kna1
                              fp_i_t151     type ty_t_t151
                              fp_i_tvv1     type ty_t_tvv1
                              fp_i_tvv2     type ty_t_tvv2
                              fp_i_edpar    type ty_t_edpar.

*Local internal Table declarations
  data :
         li_mara  type ty_t_mara,
         li_tvko  type ty_t_tvko,
         li_tvtw  type ty_t_tvtw,
         li_kna1  type ty_t_kna1,
         li_t151  type ty_t_t151,
         li_tvv1  type ty_t_tvv1,
         li_tvv2  type ty_t_tvv2,
         li_edpar type ty_t_edpar,

*Local work areas
         lwa_mara  type ty_mara,
         lwa_tvko  type ty_tvko,
         lwa_tvtw  type ty_tvtw,
         lwa_kna1  type ty_kna1,
         lwa_t151  type ty_t151,
         lwa_tvv1  type ty_tvv1,
         lwa_tvv2  type ty_tvv2,
         lwa_edpar type ty_edpar.

* Local Data Declaration.
  field-symbols: <lfs_input> type ty_input.

*collecting the data of input file into separate tables for validations
  loop at  fp_i_input assigning <lfs_input>.
*Conver VBELN to its internal format
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = <lfs_input>-vbeln
      importing
        output = <lfs_input>-vbeln.

*Assign Material to an internal table for validation purpose

*Convert Material to Its internal format
    call function 'CONVERSION_EXIT_MATN1_INPUT'
      exporting
        input  = <lfs_input>-matnr
      importing
        output = <lfs_input>-matnr.

    lwa_mara-matnr = <lfs_input>-matnr.
    append lwa_mara to li_mara.

*Start Of Defect 628
**Convert Material to Its internal format
*    call function 'CONVERSION_EXIT_MATN1_INPUT'
*      exporting
*        input  = <lfs_input>-zzcus_mat_no
*      importing
*        output = <lfs_input>-zzcus_mat_no.
**Assign Customer Material to an internal table for validation purpose
*    lwa_mara-matnr = <lfs_input>-zzcus_mat_no.
*    append lwa_mara to li_mara.
*End Of Defect 628


*Assign Sales Organization to an internal table for validation purpose
    lwa_tvko-vkorg = <lfs_input>-vkorg.
    append lwa_tvko to li_tvko.

*Assign Distribution Channel to an internal table for validation purpose
    lwa_tvtw-vtweg = <lfs_input>-vtweg.
    append lwa_tvtw to li_tvtw.

*Convert Customer to Its internal format
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = <lfs_input>-kunnr
      importing
        output = <lfs_input>-kunnr.
*Assign Material to an internal table for validation purpose
    lwa_kna1-kunnr = <lfs_input>-kunnr.
    append lwa_kna1 to li_kna1.
    clear lwa_kna1.

*Convert Sold to Party to Its internal format
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = <lfs_input>-kunag
      importing
        output = <lfs_input>-kunag.
*Assign Material to an internal table for validation purpose
    lwa_kna1-kunnr = <lfs_input>-kunag.
    append lwa_kna1 to li_kna1.

*Assign Customer Group to an internal table for validation purpose
    lwa_t151-kdgrp = <lfs_input>-kdgrp.
    append lwa_t151 to li_t151.

*Assign Customer Group 1 to an internal table for validation purpose
    lwa_tvv1-kvgr1 = <lfs_input>-kvgr1.
    append lwa_tvv1 to li_tvv1.

*Assign Customer Group 2 to an internal table for validation purpose
    lwa_tvv2-kvgr2 = <lfs_input>-kvgr2.
    append lwa_tvv2 to li_tvv2.

*Assign KUNNR/ EXPNR to an internal table for validation purpose
    lwa_edpar-kunnr = <lfs_input>-kunnr.
    lwa_edpar-expnr = <lfs_input>-expnr.
    append lwa_edpar to li_edpar.

    clear : lwa_mara,
            lwa_t151,
            lwa_tvv1,
            lwa_tvv2,
            lwa_kna1,
            lwa_tvtw,
            lwa_edpar,
            lwa_tvko.
  endloop.

  sort li_mara by matnr.
  delete adjacent duplicates from li_mara comparing matnr.
  if not li_mara is initial.
*START DEFECT 1353
*     Retreiving material from MARA based on input file
*    select matnr "Material
*      from mara
*      into table fp_i_mara
*      for all entries in li_mara
*      where matnr = li_mara-matnr.
*    if sy-subrc is initial.
*      sort fp_i_mara by matnr.
*    endif.
*     Retreiving material & product Family from MARA based on input file
      select matnr "Material
             prdha "Product Family
      from mara
      into table fp_i_mara
      for all entries in li_mara
      where matnr = li_mara-matnr.
    if sy-subrc is initial.
      sort fp_i_mara by matnr.
    endif.

*END DEFECT 1353
  endif.

  sort li_tvko by vkorg.
  delete adjacent duplicates from li_tvko comparing vkorg.
  if not li_tvko is initial.
*     Retreiving Sales Organization from TVKO based on input file
    select vkorg "Sales Organization
      from tvko
      into table fp_i_tvko
      for all entries in li_tvko
      where vkorg = li_tvko-vkorg.
    if sy-subrc is initial.
      sort fp_i_tvko by vkorg.
    endif.
  endif.

  sort li_tvtw by vtweg.
  delete adjacent duplicates from li_tvtw comparing vtweg.
  if not li_tvtw is initial.
*     Retreiving Distribution Channel from TVTW based on input file
    select vtweg "Distribution Channel
      from tvtw
      into table fp_i_tvtw
      for all entries in li_tvtw
      where vtweg = li_tvtw-vtweg.
    if sy-subrc is initial.
      sort fp_i_tvtw by vtweg.
    endif.
  endif.

  sort li_kna1 by kunnr.
  delete adjacent duplicates from li_kna1 comparing kunnr.
  if not li_kna1 is initial.
*     Retreiving Customer from KNA1 based on input file
    select kunnr "Distribution Channel
      from kna1
      into table fp_i_kna1
      for all entries in li_kna1
      where kunnr = li_kna1-kunnr.
    if sy-subrc is initial.
      sort fp_i_kna1 by kunnr.
    endif.
  endif.

  sort li_t151 by kdgrp.
  delete adjacent duplicates from li_t151 comparing kdgrp.
  if not li_t151 is initial.
*     Retreiving Customer Group from T151 based on input file
    select kdgrp "Customer Group
      from t151
      into table fp_i_t151
      for all entries in li_t151
      where kdgrp = li_t151-kdgrp.
    if sy-subrc is initial.
      sort fp_i_t151 by kdgrp.
    endif.
  endif.


  sort li_tvv1 by kvgr1.
  delete adjacent duplicates from li_tvv1 comparing kvgr1.
  if not li_tvv1 is initial.
*     Retreiving Customer Group 1 from TVV1 based on input file
    select kvgr1 "Customer Group 1
      from tvv1
      into table fp_i_tvv1
      for all entries in li_tvv1
      where kvgr1 = li_tvv1-kvgr1.
    if sy-subrc is initial.
      sort fp_i_tvv1 by kvgr1.
    endif.
  endif.

  sort li_tvv2 by kvgr2.
  delete adjacent duplicates from li_tvv2 comparing kvgr2.
  if not li_tvv2 is initial.
*     Retreiving Customer Group 2 from TVV2 based on input file
    select kvgr2 "Customer Group 2
      from tvv2
      into table fp_i_tvv2
      for all entries in li_tvv2
      where kvgr2 = li_tvv2-kvgr2.
    if sy-subrc is initial.
      sort fp_i_tvv2 by kvgr2.
    endif.
  endif.

  sort li_edpar by kunnr expnr.
  delete adjacent duplicates from li_edpar comparing kunnr expnr.
  if not li_edpar is initial.
*    Retrieving Distributor customer code
    select kunnr   "Customer
           expnr   "Distributor customer code
      from edpar
      into table fp_i_edpar
      for all entries in li_edpar
      where kunnr = li_edpar-kunnr
        and expnr = li_edpar-expnr
        and parvw = c_shipto.
    if sy-subrc = 0.
      sort fp_i_edpar by kunnr expnr.
    endif.
  endif.

endform.                    " F_GET_DB_VALUES
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*       Validating the Input data
*----------------------------------------------------------------------*
*      <--FP_I_INPUT[]    Input Records
*      <--FP_I_INPUT_E[]  Input error records
*      <--FP_I_REPORT[]   Error log
*      -->FP_I_MARA[]     Material Records
*      -->FP_I_TVKO[]     Sales Organization Records
*      -->FP_I_TVTW[]     Distribution Channel Records
*      -->FP_I_KNA1[]     Customer Records
*      -->FP_I_T151[]     GPO Code Records
*      -->FP_I_TVV1[]     Buying Group Records
*      -->FP_I_TVV2[]     IDN code Records
*      -->FP_I_EDPAR[]    Customer Distributor code
*----------------------------------------------------------------------*
form f_validate_input using fp_i_mara     type ty_t_mara
                            fp_i_tvko     type ty_t_tvko
                            fp_i_tvtw     type ty_t_tvtw
                            fp_i_kna1     type ty_t_kna1
                            fp_i_t151     type ty_t_t151
                            fp_i_tvv1     type ty_t_tvv1
                            fp_i_tvv2     type ty_t_tvv2
                            fp_i_edpar    type ty_t_edpar
                   changing fp_i_report   type ty_t_report
                            fp_i_input_e  type ty_t_input_e
                            fp_i_input    type ty_t_input.

* Local Data Declaration.
  field-symbols: <lfs_input> type ty_input. "Field symbol for input data

  data : lv_key        type string,       "key for error log
         lv_error      type char1,        "Error Flag
         lwa_report    type ty_report.    "Work area for error log table

  loop at fp_i_input assigning <lfs_input>.

*   Forming the Message key from record in case error report is needed.
    perform f_form_key using    <lfs_input>
                       changing lv_key.
*   Clear error flag
    clear lv_error.

*   VAlidating Invoice Number
*    It should not empty
    if <lfs_input>-vbeln is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Invoice Number is missing'(m15).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   VAlidating Position Number
*    It should not empty
    if <lfs_input>-posnr is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Position Number is missing'(m17).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   VAlidating Material Number
*    It should not empty
    if <lfs_input>-matnr is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Material Number is missing'(m18).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    else.
*Validate Material Number
      read table fp_i_mara with key matnr = <lfs_input>-matnr
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'Material'(h03)
                          <lfs_input>-matnr
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating Sales Organization
    if <lfs_input>-vkorg is not initial.
*Validate Sales Organization
      read table fp_i_tvko with key vkorg = <lfs_input>-vkorg
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'Sales Organization'(h04)
                          <lfs_input>-vkorg
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating Distribution Channel
*    It should not empty
    if <lfs_input>-vtweg is not initial.
*Validate Distribution Channel
      read table fp_i_tvtw with key vtweg = <lfs_input>-vtweg
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'Distribution Channel'(h05)
                          <lfs_input>-vtweg
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating Sold - to - party
*    It should not empty
    if <lfs_input>-kunag is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Sold to party is missing'(m21).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    else.
*Validate Distribution Channel
      read table fp_i_kna1 with key kunnr = <lfs_input>-kunag
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'Sold-to party'(h06)
                          <lfs_input>-kunag
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

    if not <lfs_input>-kunnr is initial.
*Validate End Customer Number
      read table fp_i_kna1 with key kunnr = <lfs_input>-kunnr
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'End Customer'(h07)
                          <lfs_input>-kunnr
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating Legacy Invoice Type
*    It should not empty
    if <lfs_input>-zzleg_inv_typ is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Legacy Invoice Type is missing'(m23).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   VAlidating Legacy Sales Order Number
*    It should not empty
    if <lfs_input>-zzleg_so is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Legacy SO Number is missing'(m24).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   VAlidating Invoice Date
*    It should not empty
    if <lfs_input>-fkdat is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Invoice Date is missing'(m25).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   BOC DEL ADAS1 D#597 10/25/2012
*   ZZCUS_MAT_NO and EXPNR fields should not be mandatory for loading.
*   Also, need to remove check table EDPAR(PARVW = SH) for Distributor
*   Customer Code (Cardinal Customer Code).

*   VAlidating Distributor Customer code
*    if  not <lfs_input>-expnr is initial
*      and not <lfs_input>-kunnr is initial.
*
*      read table fp_i_edpar with key kunnr = <lfs_input>-kunnr
*                                     expnr = <lfs_input>-expnr
*                                     transporting no fields
*                                     binary search.
*      if sy-subrc ne 0.
*        lv_error = c_true.
*        lwa_report-key    = lv_key.
*        lwa_report-msgtyp = c_error.
**Forming the Message
*        message i000 with 'Distributor Customer Code'(h13)
*                          <lfs_input>-expnr
*                          'does not exist'(m16)
*        into lwa_report-msgtxt.
**Populating the Error Log
*        append  lwa_report to fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*        perform f_populate_error_table using <lfs_input>
*                                             lwa_report
*                                    changing fp_i_input_e.
*        clear lwa_report.
*      endif.
*    endif.
*   EOC DEL ADAS1 D#597 10/25/2012

*   VAlidating PO Date
*    It should not empty
    if <lfs_input>-bstdk is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field PO Date is missing'(m26).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*Start Of Defect 628
**   VAlidating Customer Material Number
*    if  not <lfs_input>-zzcus_mat_no is initial.
*
*      read table fp_i_mara with key matnr = <lfs_input>-zzcus_mat_no
*                                     transporting no fields
*                                     binary search.
*      if sy-subrc ne 0.
*        lv_error = c_true.
*        lwa_report-key    = lv_key.
*        lwa_report-msgtyp = c_error.
**Forming the Message
*        message i000 with 'Customer Material'(h16)
*                          <lfs_input>-fkart
*                          'does not exist'(m16)
*        into lwa_report-msgtxt.
**Populating the Error Log
*        append  lwa_report to fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*        perform f_populate_error_table using <lfs_input>
*                                             lwa_report
*                                    changing fp_i_input_e.
*        clear lwa_report.
*      endif.
*    endif.
*End Of Defect 628




*   VAlidating Invoiced Quantity
*    It should not empty
    if <lfs_input>-fkimg is initial.
      lv_error = c_true.
      lwa_report-key    = lv_key.
      lwa_report-msgtyp = c_error.
*Forming the Message
      lwa_report-msgtxt = 'Mandatory field Invoiced Quantity is missing'(m28).
*Populating the Error Log
      append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      perform f_populate_error_table using <lfs_input>
                                            lwa_report
                                  changing fp_i_input_e.
      clear lwa_report.
    endif.

*   VAlidating GPO Code
    if  not <lfs_input>-kdgrp is initial.

      read table fp_i_t151 with key kdgrp = <lfs_input>-kdgrp
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'GPO Code'(h33)
                          <lfs_input>-kdgrp
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating Buying Group
    if  not <lfs_input>-kvgr1 is initial.

      read table fp_i_tvv1 with key kvgr1 = <lfs_input>-kvgr1
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'Buying Group'(h19)
                          <lfs_input>-kvgr1
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*   VAlidating IDN Code
    if  not <lfs_input>-kvgr2 is initial.

      read table fp_i_tvv2 with key kvgr2 = <lfs_input>-kvgr2
                                     transporting no fields
                                     binary search.
      if sy-subrc ne 0.
        lv_error = c_true.
        lwa_report-key    = lv_key.
        lwa_report-msgtyp = c_error.
*Forming the Message
        message i000 with 'IDN Code'(h20)
                          <lfs_input>-kvgr2
                          'does not exist'(m16)
        into lwa_report-msgtxt.
*Populating the Error Log
        append  lwa_report to fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        perform f_populate_error_table using <lfs_input>
                                             lwa_report
                                    changing fp_i_input_e.
        clear lwa_report.
      endif.
    endif.

*CR 149 Start of change 08/23
**   VAlidating Sales Price
**    It should not empty
*    IF <lfs_input>-netwr IS INITIAL.
*      lv_error = c_true.
*      lwa_report-key    = lv_key.
*      lwa_report-msgtyp = c_error.
**Forming the Message
*      lwa_report-msgtxt = 'Mandatory field Sales Price is missing'(m29).
**Populating the Error Log
*      APPEND  lwa_report TO fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*      PERFORM f_populate_error_table USING <lfs_input>
*                                            lwa_report
*                                  CHANGING fp_i_input_e.
*      CLEAR lwa_report.
*    ENDIF.


**   VAlidating Contract Price
**    It should not empty
*    IF <lfs_input>-zzcont_price IS INITIAL.
*      lv_error = c_true.
*      lwa_report-key    = lv_key.
*      lwa_report-msgtyp = c_error.
**Forming the Message
*      lwa_report-msgtxt = 'Mandatory field Contract Price is missing'(m30).
**Populating the Error Log
*      APPEND  lwa_report TO fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*      PERFORM f_populate_error_table USING <lfs_input>
*                                            lwa_report
*                                  CHANGING fp_i_input_e.
*      CLEAR lwa_report.
*    ENDIF.
**   VAlidating Settled Quantity
**    It should not empty
*    IF <lfs_input>-zzset_qty IS INITIAL.
*      lv_error = c_true.
*      lwa_report-key    = lv_key.
*      lwa_report-msgtyp = c_error.
**Forming the Message
*      lwa_report-msgtxt = 'Mandatory field Settled Qty is missing'(m31).
**Populating the Error Log
*      APPEND  lwa_report TO fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*      PERFORM f_populate_error_table USING <lfs_input>
*                                            lwa_report
*                                  CHANGING fp_i_input_e.
*      CLEAR lwa_report.
*    ENDIF.
*
**   VAlidating Balanced Quantity
**    It should not empty
*    IF <lfs_input>-zzbal_qty IS INITIAL.
*      lv_error = c_true.
*      lwa_report-key    = lv_key.
*      lwa_report-msgtyp = c_error.
**Forming the Message
*      lwa_report-msgtxt = 'Mandatory field Balanced Qty is missing'(m32).
**Populating the Error Log
*      APPEND  lwa_report TO fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*      PERFORM f_populate_error_table USING <lfs_input>
*                                            lwa_report
*                                  CHANGING fp_i_input_e.
*      CLEAR lwa_report.
*    ENDIF.
*
**VAlidating Old/New Sale Indicator
**    It should not empty
*    IF <lfs_input>-zzold_new_ind IS INITIAL.
*      lv_error = c_true.
*      lwa_report-key    = lv_key.
*      lwa_report-msgtyp = c_error.
**Forming the Message
*      lwa_report-msgtxt = 'Mandatory field Old/New Sale Indicator is missing'(m34).
**Populating the Error Log
*      APPEND  lwa_report TO fp_i_report.
**   Populating the Error Record table for Application server download
**   in case Application Server option is chosen
*      PERFORM f_populate_error_table USING <lfs_input>
*                                            lwa_report
*                                  CHANGING fp_i_input_e.
*      CLEAR lwa_report.
*    ENDIF.

*CR 149 End of change 08/23



*   If Validation fails, LV_ERROR becomes X. Discarding the errornous
*   records for further processing
    if lv_error = c_true.
      clear <lfs_input>-vbeln.
*     Increasing the Error Counter by 1
      gv_error = gv_error + 1.
*     Setting the Global Error Flag ON
      gv_err_flg = c_true.
    else.
*Increasing the Success count by 1
      gv_succ = gv_succ + 1.
    endif.
  endloop.
  if gv_err_flg is initial
    and rb_post is initial.
    lwa_report-msgtyp = c_success.
*Forming the Message
    message i007
    into lwa_report-msgtxt.
*Populating the Error Log
    append  lwa_report to fp_i_report.
    clear lwa_report.
  endif.
* Deleting the Removed entries where error happened.
  delete fp_i_input where vbeln is initial.
endform.                    "f_validate_input
*&---------------------------------------------------------------------*
*&      Form  F_INSERT
*&---------------------------------------------------------------------*
*       Creating Classes
*----------------------------------------------------------------------*
*      -->FP_I_INPUT   Input Data
*      <--FP_I_REPORT  Report
*----------------------------------------------------------------------*
form f_insert      using    fp_i_input    type ty_t_input
                   changing fp_i_report   type ty_t_report.

  data : lwa_report    type ty_report,     "Work area for error log table
         lwa_final     type zotc_billback, "work area with MANDT field
         li_final      type standard table of zotc_billback
                       initial size 0.     "table with MANDT field

  field-symbols: <lfs_input> type ty_input."without MANDT Field
*START DEFECT 1353
  field-symbols: <lfs_mara> type ty_mara.
*END DEFECT 1353

  loop at fp_i_input assigning <lfs_input>.
    lwa_final-mandt            = sy-mandt.
    lwa_final-vbeln            = <lfs_input>-vbeln.
    lwa_final-posnr            = <lfs_input>-posnr.
    lwa_final-matnr            = <lfs_input>-matnr.
    lwa_final-vkorg            = <lfs_input>-vkorg.
    lwa_final-vtweg            = <lfs_input>-vtweg.
    lwa_final-kunag            = <lfs_input>-kunag.
    lwa_final-kunnr            = <lfs_input>-kunnr.
    lwa_final-bstkd            = <lfs_input>-bstkd.
    lwa_final-fkart            = <lfs_input>-fkart.
    lwa_final-zzleg_inv_typ    = <lfs_input>-zzleg_inv_typ.
    lwa_final-zzleg_so         = <lfs_input>-zzleg_so.
    lwa_final-fkdat            = <lfs_input>-fkdat.
    lwa_final-expnr            = <lfs_input>-expnr.
    lwa_final-bstdk            = <lfs_input>-bstdk.
    lwa_final-prodh            = <lfs_input>-prodh.

*START DEFECT 1353
    if lwa_final-prodh is INITIAL.
       read table i_mara ASSIGNING <lfs_mara> with key matnr = lwa_final-matnr BINARY SEARCH.
       if sy-subrc = 0.
         lwa_final-prodh            = <lfs_mara>-prdha.
       endif.
    endif.
* END  DEFECT 1353

    lwa_final-zzcus_mat_no     = <lfs_input>-zzcus_mat_no.
    lwa_final-fkimg            = <lfs_input>-fkimg.
    lwa_final-zzgln_code       = <lfs_input>-zzgln_code.
    lwa_final-kdgrp            = <lfs_input>-kdgrp.
    lwa_final-kvgr1            = <lfs_input>-kvgr1.
    lwa_final-kvgr2            = <lfs_input>-kvgr2.
    lwa_final-netwr            = <lfs_input>-netwr.
    lwa_final-zzcont_price     = <lfs_input>-zzcont_price.
    lwa_final-zzset_qty        = <lfs_input>-zzset_qty.
    lwa_final-zzbal_qty        = <lfs_input>-zzbal_qty.
    lwa_final-zzref_inv_no     = <lfs_input>-zzref_inv_no .
    lwa_final-zzref_inv_date   = <lfs_input>-zzref_inv_date.
    lwa_final-auart            = <lfs_input>-auart.
    lwa_final-zzset_amnt       = <lfs_input>-zzset_amnt.
    lwa_final-zzold_new_ind    = <lfs_input>-zzold_new_ind.
    lwa_final-zzold_new_ind    = <lfs_input>-zzold_new_ind.
    lwa_final-zzpo_date        = <lfs_input>-zzpo_date.
    lwa_final-zzprod_family_cd = <lfs_input>-zzprod_family_cd.
    append lwa_final to li_final.
  endloop.

  call function 'ENQUEUE_EZOTC_BILLBACK'
    exporting
      mode_zotc_billback = c_emode
      mandt              = sy-mandt
    exceptions
      foreign_lock       = 1
      system_failure     = 2
      others             = 3.
  if sy-subrc <> 0.
    message i000 with 'Custom bill back table can not be locked'(m10)
    into lwa_report-msgtxt.
*Populating the Error Log
    append  lwa_report to fp_i_report.
  else.
*insert the records into table ZOTC_BILLBACK.
    insert zotc_billback from table li_final accepting duplicate keys.
    if sy-subrc = 0.
      commit work.
*Forming the Message
      message i000 with 'Billback data updated successfully from input file'(m11)
      into lwa_report-msgtxt.
*Populating the Error Log
      append  lwa_report to fp_i_report.
    else.
*Forming the Message
      message i000 with 'Billback data updation failed from input file'(m14)
      into lwa_report-msgtxt.
*Populating the Error Log
      append  lwa_report to fp_i_report.
    endif.

    call function 'DEQUEUE_EZOTC_BILLBACK'
      exporting
        mode_zotc_billback = c_emode
        mandt              = sy-mandt.
  endif.
endform.                    "f_INSERT
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Moving Source File to DONE Folder if Validate & Post option is
*       chosen
*----------------------------------------------------------------------*
*      -->FP_V_SOURCE  Source File Path
*----------------------------------------------------------------------*
form f_move using    fp_v_source type localfile
            changing fp_i_report type ty_t_report.
* Local Data
  data: lv_file   type localfile,   "File Name
        lv_name   type localfile,   "Path Name
        lv_return type sysubrc,     "Return Code
        lwa_report type ty_report.  "local work area for error log

* Spitting Filae Path & File Name
  call function '/SAPDMC/LSM_PATH_FILE_SPLIT'
    exporting
      pathfile = fp_v_source
    importing
      pathname = lv_file
      filename = lv_name.

* Changing the file path to DONE folder
  replace c_tobeprscd in lv_file with c_done_fold .
  concatenate lv_file lv_name into lv_file.
* Move the file
  perform f_file_move  using    fp_v_source
                                lv_file
                       changing lv_return.
  if lv_return is initial.
*   Assigning the archived file name to global variable
    gv_archive_gl_1 = lv_file.
  else.
* Populating the error message in case Input file not moved
    lwa_report-msgtyp = c_error.
* Forming the text.
    message i000 with 'Input file'(m08)
                       lv_file
                      'not moved.'(m09)
            into lwa_report-msgtxt.
    append lwa_report to fp_i_report.
    clear lwa_report.
  endif.

endform.                    " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*       Moving Error file to Error folder.
*----------------------------------------------------------------------*
*      -->FP_P_AFILE      Source file path
*      -->FP_I_INPUT_E[]  Error File with errorneous records
*----------------------------------------------------------------------*
form f_move_error  using  fp_p_afile    type localfile
                          fp_i_input_e  type ty_t_input_e.
* Local Data
  data: lv_file         type localfile,      "File Name
        lv_name         type localfile,      "File Name
        lv_data         type string,         "Output data string
        lv_fkimg        type char17,         "Actual Invoiced Quantity
        lv_netwr        type char21,         "Net Value in Document Currency
        lv_zzcont_price type char21,         "Contract Price
        lv_zzset_qty    type char17,         "Settled Qty
        lv_zzbal_qty    type char17,         "Balanced Qty
        lv_zzset_amnt   type char21,         "Settled Amount
        lwa_input_e     type ty_input_e.     "Error work area

* Spitting Filae Path & File Name
  call function '/SAPDMC/LSM_PATH_FILE_SPLIT'
    exporting
      pathfile = fp_p_afile
    importing
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  replace c_tobeprscd  in lv_file with c_err_fold .
  concatenate lv_file c_slash lv_name into lv_file.

* Write the records
  open dataset lv_file for output in text mode encoding default.
  if sy-subrc ne 0.
    message i000 with 'Error Folder could not be opened'(m13).
  else.
*   Forming the header text line
    concatenate  'Invoice Number'(h01)
                 'Position Number'(h02)
                 'Material'(h03)
                 'Sales Organization'(h04)
                 'Distribution Channel'(h05)
                 'Sold-to party'(h06)
                 'End Customer'(h07)
                 'PO Number'(h08)
                 'SAP Invoice Type'(h09)
                 'Legacy Invoice Type'(h10)
                 'Legacy Sales Order number'(h11)
                 'Invoice Date'(h12)
                 'Distributor Customer Code'(h13)
                 'PO date'(h14)
                 'Product Family'(h15)
                 'Customer Material'(h16)
                 'Invoiced Quantity'(h17)
                 'Legacy GLN Code'(h18)
                 'GPO Code'(h33)
                 'Buying Group'(h19)
                 'IDN Code'(h20)
                 'Sales Price'(h21)
                 'Contract Price'(h22)
                 'Settled Qty'(h23)
                 'Balanced Qty'(h24)
                 'Reference invoice for old sale'(h25)
                 'Reference invoice for old sale Date'(h26)
                 'Sales Document Type'(h27)
                 'Settled Amount'(h28)
                 'Old/New Sale Indicator'(h29)
                 'Lot Number'(h30)
                 'Reference FirstOf DropShip PO'(h31)
                 'Product Family Code'(h32)
                 'Error Message'(000)
         into lv_data
         separated by c_tab.
    transfer lv_data to lv_file.
    clear lv_data.

*Move to a character type vriables, so that it can be concatenate
    move lwa_input_e-fkimg        to lv_fkimg.            "Actual Invoiced Quantity
    move lwa_input_e-netwr        to lv_netwr.            "Net Value in Document Currency
    move lwa_input_e-zzcont_price to lv_zzcont_price.     "Contract Price
    move lwa_input_e-zzset_qty    to lv_zzset_qty.        "Settled Qty
    move lwa_input_e-zzbal_qty    to lv_zzbal_qty.        "Balanced Qty
    move lwa_input_e-zzset_amnt   to lv_zzset_amnt.       "Settled Amount

*   Passing the Erroneous Header data
    loop at fp_i_input_e into lwa_input_e.
      concatenate  lwa_input_e-vbeln           "Billing Document
                   lwa_input_e-posnr           "Billing item
                   lwa_input_e-matnr           "Material Number
                   lwa_input_e-vkorg           "Sales Organization
                   lwa_input_e-vtweg           "Distribution Channel
                   lwa_input_e-kunag           "Sold-to party
                   lwa_input_e-kunnr           "Customer Number
                   lwa_input_e-bstkd           "Customer purchase order number
                   lwa_input_e-fkart           "Billing Type
                   lwa_input_e-zzleg_inv_typ   "Legacy Invoice Type
                   lwa_input_e-zzleg_so        "Legacy Sales Order number
                   lwa_input_e-fkdat           "Billing date for billing index and printout
                   lwa_input_e-expnr           "External partner number (in customer system)
                   lwa_input_e-bstdk           "Customer purchase order date
                   lwa_input_e-prodh           "Standard data element PRODH4
                   lwa_input_e-zzcus_mat_no    "Customer Material Number
                   lv_fkimg                      "Actual Invoiced Quantity
                   lwa_input_e-zzgln_code      "Legacy GLN Code
                   lwa_input_e-kdgrp           "Customer Group
                   lwa_input_e-kvgr1           "Buying Group
                   lwa_input_e-kvgr2           "IDN Code
                   lv_netwr                      "Net Value in Document Currency
                   lv_zzcont_price               "Contract Price
                   lv_zzset_qty                  "Settled Qty
                   lv_zzbal_qty                  "Balanced Qty
                   lwa_input_e-zzref_inv_no    "Reference invoice for old sale
                   lwa_input_e-zzref_inv_date  "Reference invoice for old sale Date
                   lwa_input_e-auart           "Sales Document Type
                   lv_zzset_amnt                 "Settled Amount
                   lwa_input_e-zzold_new_ind   "Old/New Sale Indicator
                   lwa_input_e-zzlot_number    "Lot Number
                   lwa_input_e-zzpo_date       "Reference FirstOf DropShip PO
                   lwa_input_e-zzprod_family_cd"Product Family Code
                   lwa_input_e-message "Error Message
              into lv_data
              separated by c_tab.
*     Transferring the data into application server.
      transfer lv_data to lv_file.
      clear lv_data.
    endloop.
*Close Dataset
    close dataset lv_file.
  endif.
endform.                    " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH
*&---------------------------------------------------------------------*
*      TO refresh all internal tables not required anymore
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form f_refresh .
* Refresh all the internal tables after Validations
  refresh :
*START DEFECT 1153
*           i_mara,
*END DEFECT 1153
            i_tvko,
            i_t151,
            i_tvv1,
            i_tvv2,
            i_tvtw,
            i_kna1.
endform.                    " F_REFRESH
*&---------------------------------------------------------------------*
*&      Form  F_FORM_KEY
*&---------------------------------------------------------------------*
*       Forming the message key based on Chosen option
*----------------------------------------------------------------------*
*      -->FP_LFS_INPUT       Input record
*      <--FP_REPORT_KEY      Message Key
*----------------------------------------------------------------------*
form f_form_key  using    fp_lfs_input       type ty_input
                 changing fp_report_key      type string.
* Forming the Key
  concatenate fp_lfs_input-vbeln    "Invoice type
              fp_lfs_input-posnr    "Position
              fp_lfs_input-matnr    "Material
              fp_lfs_input-vkorg    "Sales Organization
              fp_lfs_input-vtweg    "Distribution channel
              fp_lfs_input-bstkd    "PO Number
         into fp_report_key
         separated by c_slash.
endform.                    " F_FORM_KEY
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_ERROR_TABLE
*&---------------------------------------------------------------------*
*       Populating the Error Record table for Application server
*       download in case Application Server option is chosen
*----------------------------------------------------------------------*
*      -->FP_LFS_INPUT   Input record
*      -->FP_lwa_report  Error details
*      <--FP_I_INPUT_E   Error file to download
*----------------------------------------------------------------------*
form f_populate_error_table using fp_lfs_input  type ty_input
                                  fp_lwa_report type ty_report
                         changing fp_i_error    type ty_t_input_e.
* Local Data
  data: lwa_error type ty_input_e.

  lwa_error-vbeln            = fp_lfs_input-vbeln.
  lwa_error-posnr            = fp_lfs_input-posnr.
  lwa_error-matnr            = fp_lfs_input-matnr.
  lwa_error-vkorg            = fp_lfs_input-vkorg.
  lwa_error-vtweg            = fp_lfs_input-vtweg.
  lwa_error-kunag            = fp_lfs_input-kunag.
  lwa_error-kunnr            = fp_lfs_input-kunnr.
  lwa_error-bstkd            = fp_lfs_input-bstkd.
  lwa_error-fkart            = fp_lfs_input-fkart.
  lwa_error-zzleg_inv_typ    = fp_lfs_input-zzleg_inv_typ.
  lwa_error-zzleg_so         = fp_lfs_input-zzleg_so.
  lwa_error-fkdat            = fp_lfs_input-fkdat.
  lwa_error-expnr            = fp_lfs_input-expnr.
  lwa_error-bstdk            = fp_lfs_input-bstdk.
  lwa_error-prodh            = fp_lfs_input-prodh.
  lwa_error-zzcus_mat_no     = fp_lfs_input-zzcus_mat_no.
  lwa_error-fkimg            = fp_lfs_input-fkimg.
  lwa_error-zzgln_code       = fp_lfs_input-zzgln_code.
  lwa_error-kdgrp            = fp_lfs_input-kdgrp.
  lwa_error-kvgr1            = fp_lfs_input-kvgr1.
  lwa_error-kvgr2            = fp_lfs_input-kvgr2.
  lwa_error-netwr            = fp_lfs_input-netwr.
  lwa_error-zzcont_price     = fp_lfs_input-zzcont_price.
  lwa_error-zzset_qty        = fp_lfs_input-zzset_qty.
  lwa_error-zzbal_qty        = fp_lfs_input-zzbal_qty.
  lwa_error-zzref_inv_no     = fp_lfs_input-zzref_inv_no .
  lwa_error-zzref_inv_date   = fp_lfs_input-zzref_inv_date.
  lwa_error-auart            = fp_lfs_input-auart.
  lwa_error-zzset_amnt       = fp_lfs_input-zzset_amnt.
  lwa_error-zzold_new_ind    = fp_lfs_input-zzold_new_ind.
  lwa_error-zzold_new_ind    = fp_lfs_input-zzold_new_ind.
  lwa_error-zzpo_date        = fp_lfs_input-zzpo_date.
  lwa_error-zzprod_family_cd = fp_lfs_input-zzprod_family_cd.
  lwa_error-message          = fp_lwa_report-msgtxt.
  append lwa_error to fp_i_error.
  clear lwa_error.
endform.                    " F_POPULATE_ERROR_TABLE
