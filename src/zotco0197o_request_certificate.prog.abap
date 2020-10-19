*&---------------------------------------------------------------------*
*& REPORT  ZOTCO0197O_REQUEST_CERTIFICATE
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCO0197O_REQUEST_CERTIFICATE                         *
* TITLE      :  Request Certificate of Origin                          *
* DEVELOPER  :  NEHA GARG                                              *
* OBJECT TYPE:  INTERFACE                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0197_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: For the Billing number and details provided by user     *
*              Submit request to CERTIFY website using proxy call to   *
*              the website, to request for certificate of Origin       *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-JUL-2016 NGARG E1DK919089 INITIAL DEVELOPMENT                     *
*&---------------------------------------------------------------------*
* 18-OCT-2016 MGARG   E1DK919089  D3_CR_0077&Defect_4188:              *
*                                 Build two BRFPLUS tables to store    *
*                                 commodity code desc& User logon      *
*                                 information. Added code to fetch EMI *
*                                 entries as country(sel_low)value     *
*&---------------------------------------------------------------------*
* 09-Dec-2016 NGARG  E1DK919089 Defect#7379 : Copy billing document to *
*                               OBSERVATION field , Convert currency to*
*                               USD and then to sold to  party         *
*                               country's curency , and add street to  *
*                               recipient address                      *
*&---------------------------------------------------------------------*
* 18-May-2017 U033876  E1DK928015 Defect#2798 : Incident INC0338515    *
*                                Populated Ship-To Address Instead of  *
*                               Sold-To in IDD_0197 Interface Program  *
*----------------------------------------------------------------------*
REPORT zotco0197o_request_certificate NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      LINE-COUNT 100
                                      MESSAGE-ID zotc_msg.

INCLUDE zotcn0197o_request_cert_top. " Include program for data declaration

INCLUDE zotcn0197o_request_cert_sel. " Inlcude program for selection screen

INCLUDE zotcn0197o_request_cert_sub. " Include program for subroutines

INITIALIZATION.
* Initialize
  PERFORM f_initialization.

*Validate Bill Type
AT SELECTION-SCREEN ON p_fkart.
  PERFORM f_validation_fkart USING i_status.

AT SELECTION-SCREEN ON p_vbeln.
  PERFORM f_validation_vbeln CHANGING i_vbrk.


AT SELECTION-SCREEN OUTPUT.

* Modify Selection screen based on user input
  PERFORM f_modify_sel_screen.
* Fill Dropdowns
  PERFORM f_fill_ss_listboxes
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
                           USING i_status.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG


START-OF-SELECTION.

* Fetch data from database based on user input
  PERFORM f_get_data USING i_status
                    CHANGING  i_vbrk
                              i_vbrp
                              i_vbfa
* Begin of change for defect 2798- E1DK928015 by u033876.
                              i_vbpa
                              i_adrc
* End of change for defect 2798-  E1DK928015 by u033876.
                              i_likp
                              i_kna1
                              i_eikp
                              i_eipo
                              i_vekp.


END-OF-SELECTION.

* Create 2 consolidated tables
  PERFORM f_set_data USING      i_vbrk
                                i_vbrp
                                i_vbfa
*----> Begin of change for defect 2798- E1DK928015 by u033876.
                                i_vbpa
                                i_adrc
*<---- End of change for defect 2798- E1DK928015 by u033876.
                                i_likp
                                i_kna1
                                i_eikp
                                i_eipo
                                i_status
                                i_vekp
                        CHANGING i_data
                                 i_data_item.


* If no data is found for given criteria show user error message
  IF i_data[] IS INITIAL.
    MESSAGE i095. " No Data Found For The Given Selection Criteria .
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_data[] IS INITIAL

*   Send data to Certify system using proxies
    PERFORM f_call_proxy USING i_status
                               i_data_item
                               i_data.
  ENDIF. " IF i_data[] IS INITIAL
*************************************************************************
