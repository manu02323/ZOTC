*************************************************************************
** PROGRAM    :  ZOTCN0011_ITALY_E_INVOICING                                              *
** TITLE      :  D3_OTC_IDD_0011                                        *
** DEVELOPER  :  Khushboo Mishra                                        *
** OBJECT TYPE:  Interface                                              *
** SAP RELEASE:  SAP ECC 6.0                                            *
**----------------------------------------------------------------------*
** WRICEF ID  :  D3_OTC_IDD_0011                                        *
**----------------------------------------------------------------------*
** DESCRIPTION: Outbound Customer Invoices EDI 810                      *
**----------------------------------------------------------------------*
** Initial Development:                                                *
**======================================================================*
** DATE         USER      TRANSPORT   DESCRIPTION                       *
** ===========  ========  ==========  ==================================*
** 07-Jan-2019  U033632   E1DK939647 Defect#7538/SCTASK0768470: Italy   *
**                                   E-Invoicing change:Populate Bill-to*
*                                    VAT  Reg. No for ZEIT and ZEIP     *
*                                     output type                       *
*************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011_ITALY_E_INVOICING
*&---------------------------------------------------------------------*
DATA: lv_stceg TYPE stceg. " VAT Registration Number

CLEAR:lv_kunnr,
      lv_stceg.
READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDKA1' sdata+0(3) = lc_parvw_re.
IF  sy-subrc EQ 0 AND <lfs_edidd> IS ASSIGNED.
*Get Customer no
  lv_kunnr = <lfs_edidd>-sdata+3(10).
  IF lv_kunnr NE space.
*Get VAT Registration no. for that customer no from table KNA1
    SELECT SINGLE stceg " VAT Registration Number
      INTO (lv_stceg)
      FROM kna1         " General Data in Customer Master
      WHERE kunnr = lv_kunnr.
    CONDENSE lv_stceg.
*Populate VAt registration no in KNREF field of IDOC
    IF sy-subrc EQ 0.
      <lfs_edidd>-sdata+843(30)  = lv_stceg.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF lv_kunnr NE space
ENDIF. " IF sy-subrc EQ 0 AND <lfs_edidd> IS ASSIGNED
