*&---------------------------------------------------------------------*
*&  Include           ZOTCN0026O_CORRSP_COLLECT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0026O_CORRSP_COLLECT_TOP                          *
* TITLE      :  ZOTCR0026O - Customer Master & Corresp Collect Account *
*               Report                                                 *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0026                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This report shows tte list of customer master data with
*              the collect number details. The collect numbers are
*              stored in the Sales Text and the same is read and
*              displayed against the customer master
*              This include defines all the global data for the report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 22-JUL-2013 GNAG     E1DK911035 INITIAL DEVELOPMENT
* 06-AUG-2013 BMAJI    E1DK911035 DEFECT#53 : Add F4 for Language &
*                                 Text Object
*&---------------------------------------------------------------------*

************************************************************************
*          Global Constants declaration
************************************************************************
CONSTANTS:
  c_true       TYPE char1 VALUE 'X',     " value 'X' - true
  c_false      TYPE char1 VALUE ' '.     " value ' ' - false

************************************************************************
*          Global Type declaration
************************************************************************

TYPES:
  BEGIN OF ty_cust_name,      " Customer Name1
    kunnr TYPE kunnr,           " Customer Number
    name1 TYPE name1_gp,        " Name 1
  END OF ty_cust_name,

  BEGIN OF ty_cust_text,     " Customer texts
    kunnr TYPE kunnr,          " Customer Number
    lines TYPE tline_t,        " Customer texts
  END OF ty_cust_text,

  BEGIN OF ty_final,        " Table for the final display
    kunnr TYPE kunnr,         " Customer Number
    name1 TYPE name1_gp,      " Name 1
    text  TYPE char35,        " Text line 1
    icon  TYPE char4,         " Icon
  END OF ty_final,

*&&-- BOC of DEF#53
  BEGIN OF ty_textid,     " Text ID & desc for F4 in Sel Scr
    tdid TYPE tdid,       " Text ID
    tdtext TYPE tdtext,   " Short Text
  END OF ty_textid.
*&&-- EOC of DEF#53

************************************************************************
*          Global Table Type declaration
************************************************************************
TYPES:
  ty_t_cust_name TYPE STANDARD TABLE OF ty_cust_name, " Customer Name1
  ty_t_cust_text TYPE STANDARD TABLE OF ty_cust_text, " Customer texts
  ty_t_final     TYPE STANDARD TABLE OF ty_final,     " Final table
*&&-- BOC of DEF#53
  ty_t_textid    TYPE STANDARD TABLE OF ty_textid.    " Text ID for F4
*&&-- EOC of DEF#53

************************************************************************
*          Global Structure declaration
************************************************************************
DATA: x_layout TYPE slis_layout_alv.        " ALV layout

************************************************************************
*          Global Internal Tables declaration
************************************************************************
DATA:
  i_cust_name TYPE ty_t_cust_name,      " Customer Name1
  i_cust_text TYPE ty_t_cust_text,      " Customer texts
  i_final     TYPE ty_t_final,          " Final table
  i_fieldcat  TYPE slis_t_fieldcat_alv, " ALV field catalogue
  i_textid    TYPE ty_t_textid.         " Text ID for F4  "DEF#53

************************************************************************
*          Global Variable declaration
************************************************************************
DATA:
  gv_kunnr TYPE kunnr.             " Customer Number
