*&---------------------------------------------------------------------*
*& Report  ZOTCR0014O_GPO_ROASTER_UPLOAD
*&
************************************************************************
* PROGRAM    :  ZOTCR0014O_GPO_ROASTER_UPLOAD                           *
* TITLE      :  OTC_IDD_0014_GPO Roaster Upload                        *
* DEVELOPER  :  Kiran R Durshanapally                                  *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0014_Upload GPO Roster
*----------------------------------------------------------------------*
* DESCRIPTION: Uploading GPO Roaster into Customer Master              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 03-APR-2012 KDURSHA E1DK902473 INITIAL DEVELOPMENT                   *
* 17-Jul-2012 SPURI   E1DK902473 CR 82 . Modified Status report and*
*                                Error file column headers and position*
*&---------------------------------------------------------------------*

REPORT  ZOTCI0014O_GPO_ROSTER_UPLOAD
LINE-SIZE 255
LINE-COUNT 65
MESSAGE-ID ZOTC_MSG.

************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
INCLUDE ZOTCN014O_GPO_ROSTER_TOP.
* Selection screen for selecting the file to process
INCLUDE ZOTCN014O_GPO_ROSTER_SCR.
* Common Include
INCLUDE ZDEVNOXXX_COMMON_INCLUDE.
* Include for all subroutines
INCLUDE ZOTCN014O_GPO_ROSTER_FORM.




************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*   Modify the screen based on User action.
  PERFORM F_MODIFY_SCREEN.



************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PHDR.

  PERFORM F_HELP_L_PATH CHANGING P_PHDR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_AHDR.

  PERFORM F_HELP_APPL_PATH CHANGING P_AHDR.


************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON P_PHDR.
  IF RB_PRES = C_TRUE.
    IF P_PHDR IS NOT INITIAL.
*     Validating the Presentation File Name
      PERFORM F_VALIDATE_P_FILE USING P_PHDR.
*     Checking for ".XLS" extension.
      PERFORM F_CHECK_EXTENSION_PRES USING P_PHDR.
    ENDIF.
  ENDIF.



* Validating Input File - Application Server
AT SELECTION-SCREEN ON P_AHDR.
  IF RB_APP = C_TRUE.
    IF P_AHDR IS NOT INITIAL.

*   Checking for ".CSV" extension.
      PERFORM F_CHECK_EXTENSION_APPL USING P_AHDR.
    ENDIF.
  ENDIF.




***********************************************************************
* START-OF-SELECTION.
START-OF-SELECTION.

  IF RB_PRES IS NOT INITIAL.
*  Uploading and reading the Excel File from presentation Server
    PERFORM F_READ_EXCEL_FILE  TABLES I_GPOROASTER_INFO
                               USING  P_PHDR
                                      C_SCOL
                                      C_SROW
                                      C_ECOL
                                      C_EROW.

*     Applying Conversion exit on input data
    PERFORM F_CONVERSION_EXIT CHANGING I_GPOROASTER_INFO[].
  ENDIF.

  IF RB_APP IS NOT INITIAL.
*     If Logical File option is selected.
    IF RB_ALOG IS NOT INITIAL.
*       Retriving physical file paths from logical file name
      PERFORM F_LOGICAL_TO_PHYSICAL USING P_ALOG
                                 CHANGING GV_FILE.
    ELSE.
      GV_FILE = P_AHDR.
    ENDIF.
    PERFORM F_READ_FILE_FROM_APPSERVER TABLES I_GPOROASTER_INFO
                                   USING GV_FILE.

  ENDIF.

*
************************************************************************
** END-OF-SELECTION.
*END-OF-SELECTION.

  PERFORM F_UPDATE_CUSTOMER_MASTER USING I_GPOROASTER_INFO[]
                                   CHANGING I_ERROR_REPORT[]
                                            I_SUCC_REPORT[].


*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of updating GPO Info.
  IF RB_APP IS NOT INITIAL.
*     Once the input file is done, then moving the files to DONE folder
*       Moving Input File
    PERFORM F_MOVE USING P_AHDR.
*     In case of Application file error, passing the error info as file to Error folder.
    IF I_ERROR_REPORT IS NOT INITIAL.
    IF GV_FLAG_ERR IS NOT INITIAL.
        PERFORM F_MOVE_ERROR USING P_AHDR
                                   I_ERROR_REPORT[].
    ENDIF.
    ENDIF.

    PERFORM F_DISPLAY_ERROR_REPORT TABLES I_ERROR_REPORT.
    PERFORM F_DISPLAY_SUCCESS_REPORT TABLES I_SUCC_REPORT.
*     In case of Prsesntation file error, displaying the error report.
  ELSE.
    IF I_ERROR_REPORT IS NOT INITIAL.
      DESCRIBE TABLE I_ERROR_REPORT LINES GV_LINES.
      IF GV_LINES GT 0.
        PERFORM F_DISPLAY_ERROR_REPORT TABLES I_ERROR_REPORT.
      ENDIF.
    ENDIF.

    IF I_SUCC_REPORT IS NOT INITIAL.
      DESCRIBE TABLE I_SUCC_REPORT LINES GV_LINES.
      IF GV_LINES GT 0.
        PERFORM F_DISPLAY_SUCCESS_REPORT TABLES I_SUCC_REPORT.
      ENDIF.
    ENDIF.

  ENDIF.
