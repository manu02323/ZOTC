
************************************************************************
*Program    : ZXVDBU02                                                 *
*Title      : Order Change_EDI860                                      *
*Developer  : Jayanta Ray                                              *
*Object type: Interface                                                *
*SAP Release: SAP ECC 6.0                                              *
*----------------------------------------------------------------------*
*WRICEF ID  : D3_OTC_IDD_0206                                          *
*----------------------------------------------------------------------*
*Description: This development has been done to change sales order item*
*             based on posex value in E1EDP01 segment                  *
*----------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                 *
*======================================================================*
*Date           User          Transport             Description        *
*=========== ============== ============== ============================*
*28-Oct-2016   U033867       E1DK922873    Defect # 4955-EDI860 - Wrong*
*                                          Line Getting Updated in     *
*                                          sales order                 *
*----------------------------------------------------------------------*
*23-Apr-2019   U029267       E2DK923553    PCR#621 - Map fields Street *
*                                          2 and Street 3 to the sales *
*                                          order data (ORDCHG)         *
*----------------------------------------------------------------------*

INCLUDE zotcn0206o_order_change . " Order Change_EDI860

* ---> Begin of Insert For D3_OTC_CDD_0007 PCR#621 by U029267
INCLUDE zotcn0007o_map_street .
* <--- End of Insert For D3_OTC_CDD_0007 PCR#621 by U029267
