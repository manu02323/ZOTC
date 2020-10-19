***********************************************************************
*Program    : ZOTCN0139O_PRICE_REPORT_SEL                             *
*Title      : PRICE OVERRIDE REPORT_SEL                               *
*Developer  : Devendra Battala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_RDD_0139                                           *
*---------------------------------------------------------------------*
*Description:  Business requires a report monthly, for Invoices, whose*
* prices, have been manually overridden. They need a report at an Item*
* level, which contains the details of the prices of such Invoices    *
* along with their Order details.                                     *
* As this is a huge extract, this is to be scheduled as a background  *
* job, and user can get the output in the system spool.               *                                                         *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description *
*=========== ============== ============== ===========================*
*14-Jun-2019  U105652       E2DK924628     SCTASK0840194: Initial     *
*                                          Development                *
*&--------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*06-Aug-2019  U105652       E2DK924628    1.SCTASK0840194: Additional *
*                                          Change is added F4 help for*
*                                          s_bity Billing Type        *
*&--------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK b1.

SELECT-OPTIONS:
*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
               s_bity  FOR gv_bity  MATCHCODE OBJECT H_TVFK DEFAULT 'ZF2' OBLIGATORY,               " Global Variable for Billing Type
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
               s_sorg  FOR gv_sorg,                                                                 " Global Variable for Sales Organization
               s_disch FOR gv_disch DEFAULT '10'.                                                   " Global Variable for Distribution Channel
PARAMETERS : p_month(2) TYPE n AS LISTBOX VISIBLE LENGTH 10,                                        " Month(2) of type Numeric Text Fields
             p_year     TYPE gjahr OBLIGATORY.                                                      " Fiscal Year

SELECTION-SCREEN END OF BLOCK b1.
