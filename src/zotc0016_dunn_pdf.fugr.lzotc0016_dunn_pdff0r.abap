*----------------------------------------------------------------------*
***INCLUDE LF150F0R .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RESTORE_MHNK_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_IN  text                                            *
*      <--P_T_MHNK_EXT  text                                           *
*----------------------------------------------------------------------*
FORM restore_mhnk_ext TABLES   t_mhnk_in  STRUCTURE mhnk
                      CHANGING e_mhnk_ext LIKE mhnk_ext.

* try to locate entry
  READ TABLE t_mhnk_in WITH KEY laufd  = e_mhnk_ext-laufd
                                laufi  = e_mhnk_ext-laufi
                                koart  = e_mhnk_ext-koart
                                bukrs  = e_mhnk_ext-bukrs
                                kunnr  = e_mhnk_ext-kunnr
                                lifnr  = e_mhnk_ext-lifnr
                                cpdky  = e_mhnk_ext-cpdky
                                sknrze = e_mhnk_ext-sknrze
                                smaber = e_mhnk_ext-smaber
                                smahsk = e_mhnk_ext-smahsk.

* second guess in case of level split
  IF sy-subrc <> 0.
    READ TABLE t_mhnk_in WITH KEY laufd  = e_mhnk_ext-laufd
                                  laufi  = e_mhnk_ext-laufi
                                  koart  = e_mhnk_ext-koart
                                  bukrs  = e_mhnk_ext-bukrs
                                  kunnr  = e_mhnk_ext-kunnr
                                  lifnr  = e_mhnk_ext-lifnr
                                  cpdky  = e_mhnk_ext-cpdky
                                  sknrze = e_mhnk_ext-sknrze
                                  smaber = e_mhnk_ext-smaber.
  ENDIF.
* if entry found
  IF sy-subrc = 0.
     data ld_smahsk type mhnk-smahsk.
     ld_smahsk = e_mhnk_ext-smahsk.
     move-corresponding t_mhnk_in to e_mhnk_ext.
     e_mhnk_ext-smahsk = ld_smahsk.
     e_mhnk_ext-zinhw = 0.
     e_mhnk_ext-zinbt = 0.
*     e_mhnk_ext-mansp     = t_mhnk_in-mansp.
*     e_mhnk_ext-applk     = t_mhnk_in-applk.
*     e_mhnk_ext-cpdky_cpd = t_mhnk_in-cpdky_cpd.
*     e_mhnk_ext-cpdky_grp = t_mhnk_in-cpdky_grp.
*     e_mhnk_ext-vertn     = t_mhnk_in-vertn.
*     e_mhnk_ext-vertt     = t_mhnk_in-vertt.
*     e_mhnk_ext-busab     = t_mhnk_in-busab.
*     e_mhnk_ext-vzskz     = t_mhnk_in-vzskz.
   ENDIF.
ENDFORM.                               " RESTORE_MHNK_EXT
