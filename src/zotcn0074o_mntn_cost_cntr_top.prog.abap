************************************************************************
* PROGRAM    :  ZOTCN0074O_MNTN_COST_CNTR_TOP                          *
* TITLE      :  OTC_EDD_0074_Sales Rep Cost Center Assignment          *
* DEVELOPER  :  Debraj Haldar                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0074                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for global declaration                          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*  30-JUN-2012 DHALDAR  E1DK903043 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

*=======================================================================
*  Global TYPES Declaration
*=======================================================================

TYPES: ty_rangetab TYPE vimsellist, "Selection range for view maintenance
       ty_header   TYPE vimdesc,    "Cntrl block struct for view maintenance
       ty_namtab   TYPE vimnamtab.  "Cntrl block struct for fields
                                    "in view maintenance

*=======================================================================
* Global Table Type declaration
*=======================================================================
TYPES: ty_t_rangetab TYPE STANDARD TABLE OF ty_rangetab  INITIAL SIZE 0,    "Table type for ty_rangetab
       ty_t_header   TYPE STANDARD TABLE OF ty_header INITIAL SIZE 0,       "Table type for ty_header
       ty_t_namtab   TYPE STANDARD TABLE OF ty_namtab INITIAL SIZE 0.       "Table type for ty_namtab


*=======================================================================
* Global constant declaration
*=======================================================================
CONSTANTS: c_action_s TYPE char1 VALUE 'S', "Display mode
           c_action_u TYPE char1 VALUE 'U'. "Change mode

*=======================================================================
* Global internal table declaration
*=======================================================================
DATA: i_rangetab TYPE ty_t_rangetab, "internal table of ty_t_rangetab
      i_header TYPE ty_t_header,     "internal table of ty_t_header
      i_namtab TYPE ty_t_namtab.     "internal table of ty_t_namtab

*=======================================================================
* Global variable declaration
*=======================================================================
DATA : gv_vkorg TYPE vkorg,       "Sales Organization
       gv_auart TYPE tvak-auart,  "Sales Document Type
       gv_kunnr TYPE kunnr,       "Customer Number
       gv_action TYPE char1.      "View mode display or change
