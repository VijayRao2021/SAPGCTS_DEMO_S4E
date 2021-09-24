PROCESS BEFORE OUTPUT.

MODULE %_INIT_PBO.

MODULE %_PBO_REPORT.

MODULE %_PF_STATUS.

MODULE %_S_DOCNUM.

MODULE %_S_RCVPOR.

MODULE %_S_RCVPRT.

MODULE %_S_RCVPRN.

MODULE %_S_MESTYP.

MODULE %_S_IDOCTP.

MODULE %_S_CREDAT.

MODULE %_S_DIRECT.

MODULE %_S_STATUS.

MODULE %_END_OF_PBO.

PROCESS AFTER INPUT.

  MODULE %_BACK AT EXIT-COMMAND.

  MODULE %_INIT_PAI.

CHAIN.
  FIELD P_TABLE .
  FIELD P_SELECT.
    MODULE %_RADIOBUTTON_GROUP_SEL                           .
ENDCHAIN.

CHAIN.
  FIELD  S_DOCNUM-LOW.
  FIELD  S_DOCNUM-HIGH.
  MODULE %_S_DOCNUM.
ENDCHAIN.

CHAIN.
  FIELD  S_RCVPOR-LOW.
  FIELD  S_RCVPOR-HIGH.
  MODULE %_S_RCVPOR.
ENDCHAIN.

CHAIN.
  FIELD  S_RCVPRT-LOW.
  FIELD  S_RCVPRT-HIGH.
  MODULE %_S_RCVPRT.
ENDCHAIN.

CHAIN.
  FIELD  S_RCVPRN-LOW.
  FIELD  S_RCVPRN-HIGH.
  MODULE %_S_RCVPRN.
ENDCHAIN.

CHAIN.
  FIELD  S_MESTYP-LOW.
  FIELD  S_MESTYP-HIGH.
  MODULE %_S_MESTYP.
ENDCHAIN.

CHAIN.
  FIELD  S_IDOCTP-LOW.
  FIELD  S_IDOCTP-HIGH.
  MODULE %_S_IDOCTP.
ENDCHAIN.

CHAIN.
  FIELD  S_CREDAT-LOW.
  FIELD  S_CREDAT-HIGH.
  MODULE %_S_CREDAT.
ENDCHAIN.

CHAIN.
  FIELD  S_DIRECT-LOW.
  FIELD  S_DIRECT-HIGH.
  MODULE %_S_DIRECT.
ENDCHAIN.

CHAIN.
  FIELD  S_STATUS-LOW.
  FIELD  S_STATUS-HIGH.
  MODULE %_S_STATUS.
ENDCHAIN.


CHAIN.
  FIELD  S_DOCNUM-LOW.
  FIELD  S_DOCNUM-HIGH.
  FIELD  S_RCVPOR-LOW.
  FIELD  S_RCVPOR-HIGH.
  FIELD  S_RCVPRT-LOW.
  FIELD  S_RCVPRT-HIGH.
  FIELD  S_RCVPRN-LOW.
  FIELD  S_RCVPRN-HIGH.
  FIELD  S_MESTYP-LOW.
  FIELD  S_MESTYP-HIGH.
  FIELD  S_IDOCTP-LOW.
  FIELD  S_IDOCTP-HIGH.
  FIELD  S_CREDAT-LOW.
  FIELD  S_CREDAT-HIGH.
  FIELD  S_DIRECT-LOW.
  FIELD  S_DIRECT-HIGH.
  FIELD  S_STATUS-LOW.
  FIELD  S_STATUS-HIGH.
    MODULE %_BLOCK_1000003.
ENDCHAIN.


CHAIN.
  FIELD P_TABLE .
  FIELD P_SELECT.
  FIELD  S_DOCNUM-LOW.
  FIELD  S_DOCNUM-HIGH.
  FIELD  S_RCVPOR-LOW.
  FIELD  S_RCVPOR-HIGH.
  FIELD  S_RCVPRT-LOW.
  FIELD  S_RCVPRT-HIGH.
  FIELD  S_RCVPRN-LOW.
  FIELD  S_RCVPRN-HIGH.
  FIELD  S_MESTYP-LOW.
  FIELD  S_MESTYP-HIGH.
  FIELD  S_IDOCTP-LOW.
  FIELD  S_IDOCTP-HIGH.
  FIELD  S_CREDAT-LOW.
  FIELD  S_CREDAT-HIGH.
  FIELD  S_DIRECT-LOW.
  FIELD  S_DIRECT-HIGH.
  FIELD  S_STATUS-LOW.
  FIELD  S_STATUS-HIGH.
    MODULE %_BLOCK_1000000.
ENDCHAIN.

FIELD !P_DISWS MODULE %_P_DISWS .

FIELD !P_TVARVC MODULE %_P_TVARVC .

FIELD !P_LOGLVL MODULE %_P_LOGLVL .


CHAIN.
  FIELD P_DISWS .
  FIELD P_TVARVC .
  FIELD P_LOGLVL .
    MODULE %_BLOCK_1000015.
ENDCHAIN.

CHAIN.
  FIELD P_TABLE .
  FIELD P_SELECT.
  FIELD  S_DOCNUM-LOW.
  FIELD  S_DOCNUM-HIGH.
  FIELD  S_RCVPOR-LOW.
  FIELD  S_RCVPOR-HIGH.
  FIELD  S_RCVPRT-LOW.
  FIELD  S_RCVPRT-HIGH.
  FIELD  S_RCVPRN-LOW.
  FIELD  S_RCVPRN-HIGH.
  FIELD  S_MESTYP-LOW.
  FIELD  S_MESTYP-HIGH.
  FIELD  S_IDOCTP-LOW.
  FIELD  S_IDOCTP-HIGH.
  FIELD  S_CREDAT-LOW.
  FIELD  S_CREDAT-HIGH.
  FIELD  S_DIRECT-LOW.
  FIELD  S_DIRECT-HIGH.
  FIELD  S_STATUS-LOW.
  FIELD  S_STATUS-HIGH.
  FIELD P_DISWS .
  FIELD P_TVARVC .
  FIELD P_LOGLVL .
  MODULE %_END_OF_SCREEN.
  MODULE %_OK_CODE_1000.
ENDCHAIN.