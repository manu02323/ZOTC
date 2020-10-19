class ZCL_IM_IM_INVOIC02_EDI810 definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_INVOIC02_EDI810
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_MAPPER .
protected section.
*"* protected components of class ZCL_IM_IM_INVOIC02_EDI810
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_INVOIC02_EDI810
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_INVOIC02_EDI810 IMPLEMENTATION.


METHOD if_ex_idoc_data_mapper~process.
************************************************************************
* PROGRAM    :  OTC_IDD_0011_SAP_Outbound Customer Invoice EDI 810     *
* TITLE      :  SAP_Outbound customer invoic EDI 810                        *
* DEVELOPER  :  SHAMMI PURI                                            *
* OBJECT TYPE:  BADI METHOD                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0011                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:
* CR 204 Defect 1279
* FOLLOWING FUNCTIONALITIES ARE ACHIEVED BY IMPLEMETING BELOW BADI IMP:
* For Outbound Message type INVOIC02. Get External Number for Partner and
* Update in E1EDKA1 segment
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 07-Nov-2012   SPURI     E1DK905877  CR204 Defect 1279
* 27-May-2013   BMAJI     E1DK910518  CR147 (INC0088976) Defect # 3661
*                                     Change in logic to populate
*                                     External Vendor ID (LIFNR) onto
*                                     EDI-810 IDOC for GHX purposes
*&---------------------------------------------------------------------*
  CONSTANTS      :  c_invoic02(20)                TYPE c VALUE 'INVOIC02',  " IDOC TYPE
                    c_outbound(1)                 TYPE c VALUE '1',         " IDoc Direction
                    c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',   " SEGMENT NAME
                    c_yes(1)                      TYPE c VALUE 'X',         " SELECTED
                    c_zotc_msg(20)                TYPE c VALUE 'ZOTC_MSG',  " MESSAGE CLASS
                    c_022(3)                      TYPE c VALUE '022',

                    lc_customer_ag TYPE parvw VALUE 'AG',  "Partner Function "++CR427
                    lc_customer_we TYPE parvw VALUE 'WE'.  "Partner Function "++CR427

  DATA:      lv_parvw             TYPE parvw,
             lv_expnr             TYPE edi_expnr,
             lv_kunnr             TYPE lifnr,
             lv_inpnr             TYPE edpar-inpnr,
             lwa_mapping_rec      TYPE idoc_chang,
             lwa_data             TYPE edid4."Local work area for IDOC data "++CR427

  FIELD-SYMBOLS  :  <lfs_data>                  TYPE edid4.     " IDOC DATA


  CASE control-idoctp.
    WHEN c_invoic02.
      IF   control-direct = c_outbound.
*&&-- BOC change CR147
*&&-- SAP's sold-to party #
        READ TABLE data INTO lwa_data WITH KEY segnam     = c_e1edka1
                                               sdata+0(2) = lc_customer_ag.
        IF sy-subrc = 0.
          lv_kunnr  = lwa_data-sdata+3(17).
        ENDIF.
*&&-- EOC change CR147

*&&-- SAP's ship-to customer #
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam     = c_e1edka1
                                                      sdata+0(2) = 'WE' .
        IF sy-subrc = 0.
          CLEAR : lv_parvw,
                  lv_inpnr.
*                  lv_kunnr.  "--CR147

          lv_parvw              = <lfs_data>-sdata+0(3).
          lv_inpnr              = <lfs_data>-sdata+3(17).

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_inpnr
            IMPORTING
              output = lv_inpnr.


          CLEAR lv_expnr.

*&&-- BOC of CR147 commented
*          select     expnr
*                     from   edpar
*                     into   lv_expnr up to 1 rows
*                     where  parvw = 'WE' and
*                            inpnr = lv_inpnr .
*&&-- EOC of CR147 commented
*&&-- BOC of CR147 add
          SELECT     expnr
                     FROM   edpar
                     INTO   lv_expnr UP TO 1 ROWS
                     WHERE  kunnr = lv_kunnr AND
                            parvw = lc_customer_we AND
                            inpnr = lv_inpnr .
*&&-- EOC of CR147 commented
          ENDSELECT.
          CLEAR lv_kunnr. "++CR147

          IF sy-subrc =  0.
            IF <lfs_data>-sdata+20(17) IS INITIAL.
              CLEAR : lwa_mapping_rec.
              lwa_mapping_rec-segnum      = <lfs_data>-segnum.
              lwa_mapping_rec-feldname    = 'LIFNR'.
              lwa_mapping_rec-save_type   = c_yes.
              lwa_mapping_rec-value       = lv_expnr.
              CONDENSE lwa_mapping_rec-value NO-GAPS.
              APPEND lwa_mapping_rec TO mapping_tab.
              have_to_change  = c_yes.
              protocol-stamid = c_zotc_msg.
              protocol-stamno = c_022.
              protocol-repid  = sy-cprog .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.                    "IF_EX_IDOC_DATA_MAPPER~PROCESS
ENDCLASS.
