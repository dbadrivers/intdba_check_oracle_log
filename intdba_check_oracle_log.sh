#!/bin/bash
# get the oracle alter log ORA or Error and other Info
# by Liups dbadrivers@gmail.com  http://itopm.com 2011/1/12
# V1.0 
# how to use:
# You can copy intdba_check_oracle_log to ~/monitor,then crontal -e
# 0 * * * * sh ~/monitor/alter_log.sh 1>>~/monitor/alter_log.log 2>&1 
# every hour to check  .end
#

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi
#####if there is no ~/.bash_profile please define Oracle env

alterdir=~/monitor

if ! test -d ${alterdir}
then
        mkdir -p ${alterdir}
fi

DBAEMAIL=dbadrivers@gmail.com;export DBAEMAIL
IP=`/sbin/ifconfig eth0  |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " `
alert_dir=$ORACLE_BASE/admin/$ORACLE_SID/bdump; export alert_dir
alterlog=${alert_dir}/alert_$ORACLE_SID.log;export alertlog
err_alertlog=${alterdir}/error_alert.log;export err_alertlog
errct=`cat  $alterlog | grep 'ORA-\|rror\|Checkpoint not complete' |wc -l`
if [ $errct -ge "0" ];then
cat  $alterlog>${err_alertlog};
cat  $alterlog>>${alterlog}_all;
cat /dev/null >$alterlog;
/usr/local/bin/sendEmail -f opm@itopm.com -t $DBAEMAIL -s smtp.itopm.com -u "there_are_err_${IP}_${ORACLE_SID}_alter_log"  -o message-file=${err_alertlog} -xu "opm@itopm.com" -xp "pasword"
else
cat  $alterlog>>${alterlog}_all;
cat /dev/null >$alterlog;
echo `date +%Y%m%d%H%M` >>${alterdir}/oktime.log
fi
exit