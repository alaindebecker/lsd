#!/bin/sh
export PATH=/opt/pentaho/data-integration5:$JAVA_HOME/bin:$PATH
FAIL_MSG="exception"
TRANS_LOG=/home/pentaho/jobs/Pipeline/STAGING_Job_Assignments.log

>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###         Load ORACLE (non-HANA) STAGING Job Assignments    ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG

n=0
until [ $n -ge 5 ]
do
  kitchen.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /job:Launcher /param:dir=/StrategicFramework/Pipeline/ /param:trans=STAGING_Job_Assignments >>$TRANS_LOG 2>&1
  [ $? -eq 0 ] && break
  n=$[$n+1]
  sleep 5
done

echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###    Load ORACLE (non-HANA) STAGING Assignments Timeline    ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG

n=0
until [ $n -ge 5 ]
do
  kitchen.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /job:Launcher /param:dir=/StrategicFramework/Pipeline/ /param:trans=STAGING_Assignments_Timeline >>$TRANS_LOG 2>&1
  [ $? -eq 0 ] && break
  n=$[$n+1]
  sleep 5
done

echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###         Load HANA STAGING Job Assignments table           ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
pan.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /trans=FROM_ORACLE_TO_HANA /param:table_name=STAGING_JOB_ASSIGNMENTS level:Basic >>$TRANS_LOG 2>&1
pan.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /trans=FROM_ORACLE_TO_HANA /param:table_name=STAGING_ASSIGNMENTS_TIMELINE level:Basic >>$TRANS_LOG 2>&1


echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###        End of STAGING_Job_Assignments bash command        ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
