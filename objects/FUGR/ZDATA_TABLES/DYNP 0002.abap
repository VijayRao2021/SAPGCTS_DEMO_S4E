PROCESS BEFORE OUTPUT.
 MODULE LISTE_INITIALISIEREN.
 LOOP AT EXTRACT WITH CONTROL
  TCTRL_ZDSET_OBJECT_DAT CURSOR NEXTLINE.
   MODULE LISTE_SHOW_LISTE.
 ENDLOOP.
*
PROCESS AFTER INPUT.
 MODULE LISTE_EXIT_COMMAND AT EXIT-COMMAND.
 MODULE LISTE_BEFORE_LOOP.
 LOOP AT EXTRACT.
   MODULE LISTE_INIT_WORKAREA.
   CHAIN.
    FIELD ZDSET_OBJECT_DAT-PROCESS_ID .
    FIELD ZDSET_OBJECT_DAT-RECORD_TYPE .
    FIELD ZDSET_OBJECT_DAT-TABNAME .
    FIELD ZDSET_OBJECT_DAT-FIELDNAME .
    FIELD ZDSET_OBJECT_DAT-APPLY_CONDITION .
    FIELD ZDSET_OBJECT_DAT-DATA_SOURCE .
    FIELD ZDSET_OBJECT_DAT-NULL_ALLOWED .
    FIELD ZDSET_OBJECT_DAT-CREATION_MANDATORY .
    FIELD ZDSET_OBJECT_DAT-CHANGE_MANDATORY .
    FIELD ZDSET_OBJECT_DAT-VALUE .
    MODULE SET_UPDATE_FLAG ON CHAIN-REQUEST.
   ENDCHAIN.
   FIELD VIM_MARKED MODULE LISTE_MARK_CHECKBOX.
   CHAIN.
    FIELD ZDSET_OBJECT_DAT-PROCESS_ID .
    FIELD ZDSET_OBJECT_DAT-RECORD_TYPE .
    FIELD ZDSET_OBJECT_DAT-TABNAME .
    FIELD ZDSET_OBJECT_DAT-FIELDNAME .
    FIELD ZDSET_OBJECT_DAT-APPLY_CONDITION .
    MODULE LISTE_UPDATE_LISTE.
   ENDCHAIN.
 ENDLOOP.
 MODULE LISTE_AFTER_LOOP.