#!/usr/bin/bash

for j in 1 2 3 4 5
do
    for i in 1 2 3 4 5 6 7 8 9 10 
    do
        perl bin/cpanstats-writepages --config=data/settings.ini --update
    done
done


BASE=/opt/projects/cpantesters
LOG=$BASE/cron/cpanstats-web2.log

date_format="%Y/%m/%d %H:%M:%S"
echo `date +"$date_format"` "START" >>$LOG

echo `date +"$date_format"` "Parsing Builder logs" >>$LOG
cd /var/www/reports/toolkit
perl log-parser.pl >>$LOG 2>&1

echo `date +"$date_format"` "Creating cpanstats matrix files" >>$LOG
cd $BASE/cpanstats5
mkdir -p logs
mkdir -p data

# takes the longest to run
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --noreports                        \
     --matrix                           >>$LOG 2>&1

#     --logfile=$LOG			\
#     --logclean=1			\

cd $BASE/cpanstats-excel
mkdir -p logs

echo `date +"$date_format"` "Creating cpanstats excel files" >>$LOG
perl bin/cpanstats-writeexcel >>$LOG 2>&1

cd /var/www/reports/toolkit
perl reports-stats.pl >>LOG 2>&1

echo `date +"$date_format"` "STOP" >>$LOG


WEB=/var/www
BASE=/opt/projects/cpantesters
LOG=$BASE/cron/cpanstats-web1.log

date_format="%Y/%m/%d %H:%M:%S"
echo `date +"$date_format"` "START" >>$LOG

cd $BASE/cpanstats5
mkdir -p logs
mkdir -p data

perl bin/getmailrc.pl

echo `date +"$date_format"` "Creating cpanstats basic pages" >>$LOG
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --logclean=1                       \
     --basics --update --stats          >>$LOG 2>&1

echo `date +"$date_format"` "Updating leaderboard table" >>$LOG
perl bin/cpanstats-leaderboard   	\
     --config=data/settings.ini		\
     --update 				>>$LOG 2>&1

echo `date +"$date_format"` "Creating cpanstats site" >>$LOG
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --leader                           >>$LOG 2>&1

#     --logfile=$LOG			\
#     --logclean=1			\

echo `date +"$date_format"` "Creating cpanstats graphs" >>$LOG
perl bin/cpanstats-writegraphs		\
     --config=data/settings.ini         >>$LOG 2>&1

echo `date +"$date_format"` "STOP" >>$LOG

