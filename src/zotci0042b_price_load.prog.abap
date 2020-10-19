*&---------------------------------------------------------------------*
*& Report  ZOTCI0042B_PRICE_LOAD
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD                                  *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Bio-Rad requires an interface to handle new entries and
* changes to the Transfer Price.This will not be a real time price
* update to the ECC system, but a periodic upload of the transfer price.
* This interface gives the ability to upload Transfer Price into the ECC
* system using a flat file. The format of the upload template will be a
* tab-delimited txt file. The upload program would read the flat file and
* create transfer price condition records in the SAP system. To load the
* data from the flat file, we will use a custom transaction, which will
* be scheduled to run every mid-night.
*-----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                 *
*=======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                           *
* =========== ======== ========== ======================================*
* 05-June-2012 SPURI   E1DK901668 INITIAL DEVELOPMENT                   *
* 09-Feb-2015  NBAIS  E2DK907039  Defect #1925-(Performance Improvement)*
*                                 Improvement done in code for the      *
*                                 Performance issue in the program.     *
* 14-Feb-2015 MSINGH1 E2DK907039  Defect #1925-(Performance Improvement *
*                                 Improvement done in code for the      *
*                                 Performance issue in the program.     *
*&----------------------------------------------------------------------*
REPORT  zotci0042b_price_load MESSAGE-ID zotc_msg.
*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*
INCLUDE : zdevnoxxx_common_include, "Common include
          zotci0042n_price_load_top,"Data Decleration Include
          zotci0042n_price_load_scr,"Selection screen
          zotci0042n_price_load_sub."Subroutines
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*Hide / Unhide Screen based on user selection
  PERFORM f_modify1_screen.
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_phdr.
  IF p_phdr IS NOT INITIAL.
*    PERFORM f_validate_p_file USING p_phdr.
    CLEAR gv_extn.
*Check for text file
    PERFORM f_file_extn_check USING p_phdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e000 WITH 'Please provide text file for presentation server.'(007).
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_ahdr.
  IF  p_ahdr IS NOT INITIAL.
    CLEAR gv_extn.
*Check for text file
    PERFORM f_file_extn_check USING p_ahdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e000  WITH 'Please provide text file for application server.'(008).
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON VALUE REQUEST
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
  PERFORM f_help_l_path CHANGING p_phdr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ahdr.
  PERFORM f_help_as_path CHANGING p_ahdr.
*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF   p_phdr IS INITIAL AND
       p_ahdr IS INITIAL.

    MESSAGE i000 WITH 'Please provide the file path.'(014).
    LEAVE LIST-PROCESSING.
  ENDIF.
* Read File into internal table
  PERFORM f_upload_file1   USING p_phdr p_ahdr.
* Update Condition
  PERFORM f_upload_data.
*----------------------------------------------------------------------*
*     END OF SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
* Display Summary
  PERFORM f_display_summary.
