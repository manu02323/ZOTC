*&---------------------------------------------------------------------*
*&  Include           ZXSLLLEGCDPIR3U01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXSLLLEGCDPIR3U01                                      *
* TITLE      :  OSS 832193                                             *
* DEVELOPER  :  Shubasis Basu                                          *
* OBJECT TYPE:  User exit                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OSS 832193                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* Transfer invoice to GTS incase of domestic invoices also             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT    DESCRIPTION                        *
* =========== ======== ==========  ====================================*
* 07-SEP-2012 SBASU    E1DK905943  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

DATA : lv_fkart TYPE /sapsll/barvs_r3.

*Check the document type is for domestic invoice or not
SELECT SINGLE barvs_r3
         INTO lv_fkart
     FROM /sapsll/tler3b
      WHERE apevs_r3 = 'SD0C'
        AND barvs_r3 = is_sd0c_header-fkart.

IF sy-subrc EQ 0.
*if so mark it as 'X'
  cs_gcuma = 'X'.
ENDIF.
