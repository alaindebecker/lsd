#!/bin/sh
export PATH=/opt/pentaho/data-integration5:$JAVA_HOME/bin:$PATH
FAIL_MSG="exception"
TRANS_LOG="/home/pentaho/jobs/Meeting/STAGING_Mandates.log"
END="2020-01-01"
TODAY="`date +%D` 00:00"
#START=`date -d "$TODAY 1 months ago" +%Y-%m-%d`
START="2010-01-01"

>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###         Load ORACLE (non-HANA) STAGING Mandates            ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
n=0
until [ $n -ge 5 ]
do
  kitchen.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /job:Launcher /param:dir=/StrategicFramework/Meeting/ /param:trans=STAGING_Mandates /param:start=$START /param:end=$END level:Basic >>$TRANS_LOG 2>&1
  [ $? -eq 0 ] && break
  n=$[$n+1]
  sleep 5
done

echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###         Load HANA STAGING Mandates  table                  ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
pan.sh /rep:PentahoRepo /user:admin /pass:P3ntah0 /dir:/Utils /trans=FROM_ORACLE_TO_HANA /param:table_name=STAGING_MANDATES level:Basic >>$TRANS_LOG 2>&1


echo "                   #################################################################" >>$TRANS_LOG
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   ###            End of STAGING Mandates bash command           ###" >>$TRANS_LOG 
echo "                   ###                                                           ###" >>$TRANS_LOG
echo "                   #################################################################" >>$TRANS_LOG
