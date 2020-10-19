*&---------------------------------------------------------------------*
*& Report  ZOTCI0042B_PRICE_LOAD_WRAPPER
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD_WRAPPER                          *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: This is the wrapper program to ZOTCI0042B_PRICE_LOAD. Si*
* nce original program is taking lot of time to finish, hence objective*
* is to split the file into smaller files and schedule job with smaller*
* files                                                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*19-Nov-2015 SNIGAM   E2DK916145  Defect 1351                          *
*12-Jan-2016 PDEBARU  E2DK916678  Defect 1430 : Changing data type     *
*                                 for increasing file sublission limit *
*&---------------------------------------------------------------------*
REPORT zotci0042b_price_load_wrapper NO STANDARD PAGE HEADING
                                     LINE-SIZE  132
                                     LINE-COUNT 65
                                     MESSAGE-ID zotc_msg.

*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*
INCLUDE : zotci0042n_price_load_wrap_top, "Data Decleration Include
          zotci0042n_price_load_wrap_scr, "Selection screen
          zotci0042n_price_load_wrap_sub. "Subroutines

*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
* Clear all data
  FREE:
    i_directory,
    i_job_log.

* Get All Files in Folder
  PERFORM f_get_files CHANGING i_directory.

* Process Each File in Folder
  PERFORM f_process_file USING    i_directory
                         CHANGING i_job_log.

*----------------------------------------------------------------------*
*     END OF SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

* Display Summary
  PERFORM f_display_summary USING i_job_log.
