
FUNCTION ZOTC0016_FI_DUNNING_NOTICE_PDF.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MAHNV) LIKE  MAHNV STRUCTURE  MAHNV
*"     VALUE(I_F150V) LIKE  F150V STRUCTURE  F150V
*"     VALUE(I_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"     VALUE(I_ITCPO) LIKE  ITCPO STRUCTURE  ITCPO
*"     VALUE(I_UPDATE) TYPE  C DEFAULT SPACE
*"     VALUE(I_MOUT) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_OFI) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"  TABLES
*"      T_MHND STRUCTURE  MHND
*"      T_FIMSG STRUCTURE  FIMSG
*"  CHANGING
*"     VALUE(E_COMREQ) LIKE  BOOLE-BOOLE
*"     VALUE(E_RETCODE) TYPE  C
*"----------------------------------------------------------------------

************************************************************************
* Function Module : ZOTC0016_FI_DUNNING_NOTICE_PDF                     *
* TITLE      : OTC_FDD_0016: Sending Dunning Notice                    *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  Function Module                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_FDD_0016                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This is the the copy of the std function module         *
* FI_PRINT_DUNNING_NOTICE_PDF. This is to incorporate the email sending*
* functionality. This FM calls the FM ZOTC0016_DUNNING_NOTICE_PDF which*
* incorporates all the code additions (tagged with the TR number)      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAY-2012 GNAG     E1DK901269 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

*--------------help fields for sapf150d2
DATA:           MSGID          LIKE SY-MSGID,     "message buffer
                MSGNO          LIKE SY-MSGNO,
                MSGV1          LIKE SY-MSGV1,
                MSGV2          LIKE SY-MSGV2,
                MSGV3          LIKE SY-MSGV3,
                MSGV4          LIKE SY-MSGV4.

* Instead of the std FM, call the Z FM ZOTC0016_DUNNING_NOTICE_PDF
    CALL FUNCTION 'ZOTC0016_DUNNING_NOTICE_PDF'   "GNAG E1DK901269
         EXPORTING
              I_MAHNV     = I_MAHNV
              I_F150V     = I_F150V
              I_MHNK      = I_MHNK
              I_ITCPO     = I_ITCPO
              I_UPDATE    = I_UPDATE
              I_MOUT      = I_MOUT
              I_OFI       = I_OFI
         TABLES
              T_MHND      = T_MHND
              T_FIMSG     = T_FIMSG
         CHANGING
              E_COMREQ    = E_COMREQ
         EXCEPTIONS
              PARAM_ERROR = 1
              accnt_block = 2
              others      = 3.


  E_RETCODE = SY-SUBRC.

* count all successful print operations or issue error messages
  IF SY-SUBRC = 0.
    IF I_MOUT = 'X'.
      MESSAGE S502 WITH I_MHNK-KOART I_MHNK-KUNNR I_MHNK-LIFNR.
    ELSE.
      CLEAR T_FIMSG.
      T_FIMSG-MSGID = 'FM'.
      T_FIMSG-MSGNO = '502'.
      T_FIMSG-MSGV1 = I_MHNK-KOART.
      T_FIMSG-MSGV2 = I_MHNK-KUNNR.
      T_FIMSG-MSGV3 = I_MHNK-LIFNR.
      T_FIMSG-MSGV4 = SPACE.
      APPEND T_FIMSG.
    ENDIF.
  ELSEif sy-subrc = 1.
    MSGID = SY-MSGID.
    MSGNO = SY-MSGNO.
    MSGV1 = SY-MSGV1.
    MSGV2 = SY-MSGV2.
    MSGV3 = SY-MSGV3.
    MSGV4 = SY-MSGV4.
    IF I_MOUT = 'X'.
      MESSAGE S501 WITH I_MHNK-KOART I_MHNK-KUNNR I_MHNK-LIFNR.
      MESSAGE ID   MSGID TYPE 'S' NUMBER MSGNO
              WITH MSGV1 MSGV2 MSGV3 MSGV4.
      MESSAGE S799.
    ELSE.
     CLEAR T_FIMSG.
     T_FIMSG-MSGID = 'FM'.
     T_FIMSG-MSGNO = '501'.
     T_FIMSG-MSGV1 = I_MHNK-KOART.
     T_FIMSG-MSGV2 = I_MHNK-KUNNR.
     T_FIMSG-MSGV3 = I_MHNK-LIFNR.
     T_FIMSG-MSGV4 = SPACE.
     APPEND T_FIMSG.
     CLEAR T_FIMSG.
     T_FIMSG-MSGID = MSGID.
     T_FIMSG-MSGNO = MSGNO.
     T_FIMSG-MSGV1 = MSGV1.
     T_FIMSG-MSGV2 = MSGV2.
     T_FIMSG-MSGV3 = MSGV3.
     T_FIMSG-MSGV4 = MSGV4.
     APPEND T_FIMSG.
    ENDIF.
  ENDIF.
ENDFUNCTION.
