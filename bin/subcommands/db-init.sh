#!/bin/bash

echo "****** bootstrap starting ******"
echo $db_user @ $db_host : $db_port 

sleep 10 # need to wait for database to get going


TEST=`psql -U $db_superuser -h $db_host -lqt| cut -d \| -f 1 |grep -w $db_template| wc -l`
if [[ $TEST == 1 ]]; then
    # template database exists
    # $? is 0
    echo "******TEMPLATE DATABASE ALREADY CREATED*******"
    exit 1
else

echo "*******CREATING TEMPLATE DATABASES*******"
sudo -u www-data /bin/bash <<- EOF

    createuser -U $db_superuser -h $db_host --no-superuser \
       --createdb --no-createrole www-data
    cd /opt/liquid_feedback_core
    createdb -h $db_host liquid_feedback_template
    createlang -h $db_host plpgsql $db_template  # command may be omitted, depending on PostgreSQL version
    psql -h $db_host -v ON_ERROR_STOP=1 -f core.sql $db_template
    createdb -h $db_host -T $db_template $db_template_demo
EOF

echo "******CREATING DATBASE FROM TEMPLATE******"
    sudo -u www-data /bin/bash <<- EOF
        createdb -h $db_host -T $db_template $db_name
EOF
  
# The loop

PIDFILE="/var/run/lf_updated.pid"
PID=$$

if [ -f "${PIDFILE}" ] && kill -CONT $( cat "${PIDFILE}" ); then
  echo "lf_updated is already running."
  exit 1
fi

