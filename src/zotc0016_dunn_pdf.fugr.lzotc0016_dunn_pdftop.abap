FUNCTION-POOL ZOTC0016_DUNN_PDF MESSAGE-ID FM.

* declaration of type-pools
  TYPE-POOLS: SLIS.

* tables used by the Function group
INCLUDE  F150TBLS.

INCLUDE <cntn01>. " for BOR-Objects: Senden per Mail/Fax

INCLUDE  F150DATA.
Types :
  begin of t_sums_per_branch,
    koart     like mhnd-koart,
    bukrs     like mhnd-bukrs,
    kunnr     like mhnd-kunnr,
    lifnr     like mhnd-lifnr,
    cpdky     like mhnd-cpdky,
    sknrze    like mhnd-sknrze,
    smaber    like mhnd-smaber,
    waers     like mhnd-waers,
    dmshb(8)  type p, wrshb(8)  type p,
    famsm(8)  type p, famsh(8)  type p,
  end of t_sums_per_branch.
 data deleted_per_branch type t_sums_per_branch OCCURS 5
                                                WITH HEADER LINE.

*------- Tabelle der nicht zulaessigen OK-Codes (fuer set status excl)-*
DATA:    BEGIN OF EXCLTAB OCCURS 5,
           OKCODE(5) TYPE C,
         END OF EXCLTAB.

*------- JOBNAME für SUBMIT
DATA:    BEGIN OF JOBNAME,
           PROGN(4)          TYPE C,
           FILL1(1)          TYPE C,
           LAUFD             LIKE F150V-LAUFD,
           FILL2(1)          TYPE C,
           LAUFI             LIKE F150V-LAUFI,
           FILL3(1)          TYPE C,
           TYPE(1)           TYPE C,
         END OF JOBNAME.

DATA:    JOBSEL    LIKE BTCSELECT.

*------- Übergabeparameter für Dialogbaustein 'DELETE_JOBS'
DATA:    BEGIN OF USERSEL_JOB.
        INCLUDE STRUCTURE TBTCU.
DATA:    END OF USERSEL_JOB.

DATA:    BEGIN OF USERSEL_STATUS.
        INCLUDE STRUCTURE TBTCV.
DATA:    END OF USERSEL_STATUS.

*-------- Einzelfelder -----------------------------------------------*
DATA:    JOBS_TO_DELETE      TYPE I,   " Anz.vorh. Jobs
         JOBS_NOT_DELETED    TYPE I.   " Nicht gel. Jobs

*-------- Konstanten -------------------------------------------------*

DATA:     AEND(4)            TYPE C VALUE 'AEND',
          X(8)               TYPE C VALUE 'XXXXXXXX'.

*------- Parameter für 'Schedule_Dunning_Run'


*------- Enqueue Argumente --------------------------------------------*
DATA:    BEGIN OF ENQ,
           LAUFD   LIKE F150V-LAUFD,
           LAUFI   LIKE F150V-LAUFI,
         END OF ENQ.

*-------- Einzelfelder -----------------------------------------------*
DATA:    REFE(8)             TYPE P,   " Copy Parameters
         RCODE               LIKE SY-SUBRC,      " Schedule_Dunning_run
         ACTVT(2)            TYPE C,   " Activity f. Berecht.
         ERRTXT(25)          TYPE C,   " Errortext F. Berecht.
         JOBCOUNT(8)         TYPE C.      " Job-Nummer
*-------- Konstanten -------------------------------------------------*
DATA:     PARM               LIKE F150ID-OBJKT VALUE 'PARM'. " Copy Par.

*------- Parameter für 'GET_DUNNING_DATA_MASTER_RECORD'

*-------- Fields -----------------------------------------------------*
DATA:    SAVE_MAHST LIKE F150S-MAHST.

*-------- Internal Tables---------------------------------------------*
DATA:    BEGIN OF HF150S OCCURS 10.
           INCLUDE STRUCTURE F150S.
DATA:    END   OF HF150S.

RANGES:  HBUKRS FOR F150S-BUKRS.
RANGES:  HMABER FOR F150S-MABER.

*------- Jobs --------------------------------------------------------*
DATA:    BEGIN OF JOBTAB1 OCCURS 3.
           INCLUDE STRUCTURE TBTCJOB.
DATA:    END   OF JOBTAB1.

*------- Deklarationen 'GET_DUNNING_DATA_ACCOUNT' --------------------*
DATA:
  HT_KNB5 LIKE KNB5 OCCURS 10 WITH HEADER LINE,
  HT_LFB5 LIKE LFB5 OCCURS 10 WITH HEADER LINE,
  HI_KNB1 LIKE KNB1,
  HI_LFB1 LIKE LFB1.

DATA:
  DEBI_HAS_BRANCHES LIKE BOOLE-BOOLE,
  KRED_HAS_BRANCHES LIKE BOOLE-BOOLE.


*------- Deklarationen 'PRINT_DUNNING_NOTICE' ------------------------*
INCLUDE F150DU07.

*------- Deklarationen 'GET_DUNNING_CUSTOMIZING_SEL' ------------------*
DATA:    H_T001   LIKE T001,
         H_T047   LIKE T047,
         H_T047A  LIKE T047A,
         H_T047B  LIKE T047B,
         HT_T047B LIKE T047B OCCURS 10 WITH HEADER LINE,
         HT_T047C LIKE T047C OCCURS 10 WITH HEADER LINE,
         HT_T047H LIKE T047H OCCURS 10 WITH HEADER LINE.

*------- Deklarationen 'GENERATE_DUNNING_DATA' ------------------------*
DATA:    USE_OFI LIKE BOOLE-BOOLE.                    "open fi enable


*------- Internal Tables
DATA:    T_BSID LIKE BSID OCCURS 20 WITH HEADER LINE,
         T_BSIK LIKE BSIK OCCURS 20 WITH HEADER LINE.

* summation table for each dunning level and dunning area(key only)
DATA:    BEGIN OF LSUMTAB,
           LAUFD     LIKE MHND-LAUFD,
           LAUFI     LIKE MHND-LAUFI,
           KOART     LIKE MHND-KOART,
           BUKRS     LIKE MHND-BUKRS,
           KUNNR     LIKE MHND-KUNNR,
           LIFNR     LIKE MHND-LIFNR,
           CPDKY     LIKE MHND-CPDKY,
           SKNRZE    LIKE MHND-SKNRZE,
           SMABER    LIKE MHND-SMABER,
           SMAHSK    LIKE MHND-SMAHSK,
           MAHNN     LIKE MHND-MAHNN,  "dunning level
           WAERS     LIKE MHND-WAERS,  "Waehrung
           DMSHB(8)  TYPE P,           "Betrag in HW
           WRSHB(8)  TYPE P,           "Betrag in FW
           GSFHW(8)  TYPE P,           "Gesperrte faell. Posten HW
           GSFFW(8)  TYPE P,           "Gesperrte faell. Posten FW
           GSNHW(8)  TYPE P,           "Gesperrte n.faell. Posten HW
           GSNFW(8)  TYPE P,           "Gesperrte n.faell. Posten FW
           FAEHW(8)  TYPE P,           "Faellige Posten in HW
           FAEFW(8)  TYPE P,           "Faellige Posten in FW
           FAMSM(8)  TYPE P,           "Faellige Posten in FM ab mahns
           FAMSH(8)  TYPE P,           "Faellige Posten in HW ab mahns
         END OF LSUMTAB.

* mhnd_ext is now defined in the dictionary
*types:    BEGIN OF Y_MHND_EXT.
*           INCLUDE   STRUCTURE MHND.
*types:     GROUP(32) TYPE C,              "original group criteria
*           MGRUP     LIKE MHNK-MGRUP,
*           KONTO     LIKE MHND-KUNNR,     "account nr. for messages
*           KMANSP    LIKE MHND-MANSP,     "dunnblock account
*           GMVDT     LIKE MHNK-GMVDT,
*           PSTLZ     LIKE BSEC-PSTLZ,     "address for cpd-accounts
*           ORT01     LIKE BSEC-ORT01,
*          STRAS     LIKE BSEC-STRAS,
*           PFACH     LIKE BSEC-PFACH,
*           LAND1     LIKE BSEC-LAND1,
*          ZBD1T     LIKE FAEDE-ZBD1T,    "Additional fields used for
*          ZBD2T     LIKE FAEDE-ZBD2T,    "determination of the due date
*          ZBD3T     LIKE FAEDE-ZBD3T,
*          REBZT     LIKE FAEDE-REBZT,
*          NETDT     LIKE FAEDE-NETDT,
*          SK1DT     LIKE FAEDE-SK1DT,
*          SK2DT     LIKE FAEDE-SK2DT,
*          DMBTR     LIKE BSID-DMBTR,     "bsid fields for amount
*          WRBTR     LIKE BSID-WRBTR,
*          MANST     LIKE BSID-MANST,     "dunning level from bsid
*          CMEMO     LIKE BOOLE-BOOLE,    "not inv. rel. credit memo
*          CASGN     LIKE BOOLE-BOOLE,    " credit memo is assigned
*           DELDU     LIKE BOOLE-BOOLE,    "delete item from dunning-ntc
*          APPLK     LIKE MHNK-APPLK,     "application id mhnd
*          BLINF(25) TYPE C,
*          STATUS(8) TYPE C,
*         END OF Y_MHND_EXT.

*data mhnd_ext type y_mhnd_ext.
data mhnd_ext like mhnd_ext.

DATA:    BEGIN OF MHNK_EXT.
           INCLUDE    STRUCTURE MHNK.
DATA:      MADAT      LIKE KNB5-MADAT,     "date of the last dunning
           DTLBW      LIKE KNB5-MADAT,     "date of the last acc chng
           RHYTH      LIKE T047A-RHYTH,    "dunning period
           KONTO(15)  TYPE C,              "account nr. for messages
           UKTO(30)   TYPE C,              "branch account and/or maber
           KVERZ      LIKE MHND-VERZN,     "max account delay
           HWAERS     LIKE T001-WAERS,     "company currency
           DUNN_IT    LIKE BOOLE-BOOLE,
           LEGAL_DU   LIKE BOOLE-BOOLE,
           LEGAL_MSG  LIKE FIMSG,
           MIN_IT     LIKE BOOLE-BOOLE,
           MIN_MSG    LIKE FIMSG,          "min check for account failed
           MINZ_IT    LIKE BOOLE-BOOLE,
           MINZ_MSG   LIKE FIMSG,          "min interest check failes
           CHARGE_IT  LIKE BOOLE-BOOLE,    "charges where calculated
           CHARGE_MSG LIKE FIMSG,          "charges msg
           SUM_LEV    LIKE T047A-MAHNS,    "summation dunning level
           CAEND      TYPE P,              "counter for changed items
           CBLOCK     TYPE P,              "counter for blocked items
           CALL       TYPE P,              "counter for all items
           MINZHW     LIKE LSUMTAB-DMSHB,  "min interest cc currency
           MINZFW    LIKE LSUMTAB-WRSHB,  "min interest foreign currency
         END OF MHNK_EXT.

DATA:    BEGIN OF CPDTAB,
           CPDKY     LIKE MHND-CPDKY,
           CPDKY_CPD LIKE MHND-CPDKY,
           CPDKY_GRP LIKE MHND-CPDKY,
         END OF CPDTAB.

DATA:    BEGIN OF CHECKS,
           C_BSID LIKE BOOLE-BOOLE,
           C_BSIK LIKE BOOLE-BOOLE,
           C_KNA1 LIKE BOOLE-BOOLE,
           C_KNB1 LIKE BOOLE-BOOLE,
           C_KNB5 LIKE BOOLE-BOOLE,
           C_LFA1 LIKE BOOLE-BOOLE,
           C_LFB1 LIKE BOOLE-BOOLE,
           C_LFB5 LIKE BOOLE-BOOLE,
         END OF CHECKS.

DATA:    BEGIN OF BUKRS_SEL,
           SIGN(1),
           OPTION(2),
           LOW  LIKE MHND-BUKRS,
           HIGH LIKE MHND-BUKRS,
         END   OF BUKRS_SEL.

*------- Assign fields for dunning groups
FIELD-SYMBOLS:  <F1>, <F2>, <F3>, <F4>, <F5>, <F6>, <F7>, <F8>,
                <G1>, <G2>, <G3>, <G4>.

*------- Deklarationen 'GENERATE_DUNNING_DATA_ACCOUNT' ----------------*
DATA: TI_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE,
      OK-CODE-1002(4) TYPE C.

*------- Deklarationen 'REPRINT_DUNNING_DATA_ACCOUNT' ----------------*
DATA: H_REPRINT LIKE BOOLE-BOOLE,
      H_OFI     LIKE BOOLE-BOOLE.

*------- Deklarationen 'GET_DUNNING_ICCD_CC' -------------------------*
DATA: _T047     LIKE T047 OCCURS 10 WITH HEADER LINE.



*------- Deklarationen 'SORT_MHND' -----------------------------------*
DATA: H_T021M LIKE T021M.

DATA: BEGIN OF TTH_MHND.
        INCLUDE     STRUCTURE MHND.
DATA:   ISORT1(16)     TYPE C,
        ISORT2(16)     TYPE C,
        ISORT3(16)     TYPE C,
        ISORT4(16)     TYPE C,
        ISORT5(16)     TYPE C.
DATA: END OF TTH_MHND.

*------- assign fields sort variants
FIELD-SYMBOLS:  <H1>, <P1>, <P2>, <P3>, <P4>, <P5>.

*------- Deklarationen 'EDIT_DUNNING_DATA' ---------------------------*
DATA: EDI_MHNK LIKE MHNK,
      EDD_DISP LIKE BOOLE-BOOLE,
      EDD_MHNK LIKE MHNK OCCURS 10 WITH HEADER LINE,
      EDD_MHND LIKE MHND OCCURS 10 WITH HEADER LINE,
      CHK_MHNK LIKE MHNK OCCURS 10 WITH HEADER LINE,
      CHK_MHND LIKE MHND OCCURS 10 WITH HEADER LINE,
      TAB_IDX  LIKE SY-TABIX,
      OK-CODE-1003(4) TYPE C.

CONTROLS: TC_MHND TYPE TABLEVIEW USING SCREEN 1003,
          TC_MHNK TYPE TABLEVIEW USING SCREEN 1003.


*------- Deklaration 'F150_READ_MAHNV' --------------------------------*
DATA: H_SAVE_MAHNV LIKE MAHNV.

*------- Deklaration 'F150_LOCK_MAHNV' --------------------------------*
DATA: H_LOCK_MAHNV LIKE MAHNV.

*------- Deklaration 'F150_LOCK_MAHNV' --------------------------------*
DATA: OK-CODE-1004(4) TYPE C.

*------- Deklaration --------------------------------------------------*
DATA: OK-CODE-2001(4) TYPE C.

*------- Deklaration 'F150_CHECK_AUTHORITY ----------------------------*
DATA: T_IBKRTAB LIKE IBKRTAB OCCURS 10 WITH HEADER LINE.

DATA:    OK-CODE             LIKE SY-UCOMM.

DATA  Delay_with_blocked_items like mhnd-verzn.

*------- Data for email sending
DATA: gd_lifnr_last LIKE mhnd-lifnr,                           "1042992
      gd_kunnr_last LIKE mhnd-kunnr,                           "1042992
      gd_bukrs_last LIKE mhnd-bukrs.                           "1042992

data  gd_exit_active like boole-boole.
data  gd_pdf_is_open like boole-boole.

*------- Mahninformationen für das Collections Management
DATA:  gx_collect_single_dunn_info TYPE boole_d,
       gt_single_dunning_info      TYPE f150_t_single_dunning_info.
