*----------------------------------------------------------------------*
* PROGRAM ID        : Z_TEST_GCTS                                            *
* TITLE             :                                                  *
* PROGRAM TYPE      :                                                  *
* SUBMITTING        :                                                  *
* DEPENDENCY        :                                                  *
* TABLE UPDATES     :                                                  *
* PROGRAM EXECUTION :                                                  *
* SPECIAL LOGIC     :                                                  *
* INCLUDES          :                                                  *
* JIRA  Call NO     :                                                  *
* CREATION DATE     :                                                  *
* PROGRAMMER        :                                                  *
* DESIGNER          :                                                  *
* TCODE             :                                                  *
* RELEASE           : Developed on S4HANA 2020                         *
* OWNERSHIP         : This ABAP code must not be reproduced in whole or*
*                     in part. It must not be used except with the     *
*                     prior written consent of UMG. UMG retains all    *
*                     Intellectual Property Rights                     *
*----------------------------------------------------------------------*
* DESCRIPTION       :                                                  *
*     PURPOSE                                                          *
*      1.                                                              *
*      2.                                                              *
*                                                                      *
*      SELECTION                                                       *
*        1.                                                            *
*        2.                                                            *
*        3.                                                            *
*      OUTPUT                                                          *
*        1.                                                            *
*        2.                                                            *
*----------------------------------------------------------------------*
*                       AUTHORIZATION CHECKS                           *
*----------------------------------------------------------------------*
* OBJECT              | AUTHORITY FIELDS       |  ABAP FIELDS          *
*--------------------- ------------------------ -----------------------*
*                     |                        |                       *
*----------------------------------------------------------------------*
*                         ASSUMPTIONS                                  *
* 1.
*
* 2.                                                                   *
*                                                                      *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
*                 CHANGE HISTORY (M O D I F I C A T I O N  L O G)      *
*----------------------------------------------------------------------*
*   DATE     | NAME     | DESCRIPTION                     | Transport #*
*----------------------------------------------------------------------*
*            |          | ORIGINAL Z_TEST_GCTS   Design         |            *
*            |          |                                 |            *
*            |          |                                 |            *
*            |          |                                 |            *
************************************************************************
REPORT Z_TEST_GCTS.

START-OF-SELECTION.     "Added in Second TR

GET RUN TIME FIELD DATA(t1).
SELECT SINGLE @abap_true
FROM mara
INTO @DATA(lv_exists)
WHERE mtart = 'FERT'.
GET RUN TIME FIELD DATA(t2).

IF lv_exists = abap_true.
  WRITE:/ |Time Taken: { CONV decfloat34( (  t2 - t1 ) / 1000000 ) } seconds|.
ENDIF.

END-OF-SELECTION.   "Added in second TR
write:/ 'test via TE'.