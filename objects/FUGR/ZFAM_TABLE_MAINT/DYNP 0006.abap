PROCESS BEFORE OUTPUT.
 MODULE LISTE_INITIALISIEREN.
 LOOP AT EXTRACT WITH CONTROL
  TCTRL_ZV_FAM_RULES_GRP CURSOR NEXTLINE.
   MODULE LISTE_SHOW_LISTE.
 ENDLOOP.
 MODULE FILL_SUBSTFLDS.
*
PROCESS AFTER INPUT.
 MODULE LISTE_EXIT_COMMAND AT EXIT-COMMAND.
 MODULE LISTE_BEFORE_LOOP.
 LOOP AT EXTRACT.
   MODULE LISTE_INIT_WORKAREA.
   CHAIN.
    FIELD ZV_FAM_RULES_GRP-CRITERIAS_GROUP .
    FIELD ZV_FAM_RULES_GRP-CRITERIA .
    FIELD ZV_FAM_RULES_GRP-ITEM .
    FIELD ZV_FAM_RULES_GRP-SIGN .
    FIELD ZV_FAM_RULES_GRP-OPTI .
    FIELD ZV_FAM_RULES_GRP-LOW .
    FIELD ZV_FAM_RULES_GRP-HIGH .
    MODULE SET_UPDATE_FLAG ON CHAIN-REQUEST.
   ENDCHAIN.
   FIELD VIM_MARKED MODULE LISTE_MARK_CHECKBOX.
   CHAIN.
    FIELD ZV_FAM_RULES_GRP-CRITERIAS_GROUP .
    FIELD ZV_FAM_RULES_GRP-CRITERIA .
    FIELD ZV_FAM_RULES_GRP-ITEM .
    MODULE LISTE_UPDATE_LISTE.
   ENDCHAIN.
 ENDLOOP.
 MODULE LISTE_AFTER_LOOP.