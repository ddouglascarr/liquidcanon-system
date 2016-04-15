#!/bin/bash

echo "****** bootstrap starting ******"
sleep 10 # need to wait for database to get going

demo_data=0
test_data=0

while [ "$1" != "" ]; do
    case $1 in
        -d | --demo-data )      demo_data=1
                                ;;
        -t | --test-data )      test_data=1
                                ;;
    esac
    shift
done



TEST=`sudo -u www-data psql -U postgres -h postgres -lqt| cut -d \| -f 1 |grep -w liquid_feedback| wc -l`
if [[ $TEST == 1 ]]; then
    # database exists
    # $? is 0
    echo "******DATABASE ALREADY CREATED*******"
    exit 1
else

    echo "*******CREATING TEMPLATE DATABASES*******"
    sudo -u www-data /bin/bash <<- EOF

        createuser -U postgres -h postgres --no-superuser \
           --createdb --no-createrole www-data
        cd /opt/liquid_feedback_core
        createdb -h postgres liquid_feedback_template
        createlang -h postgres plpgsql liquid_feedback_template  # command may be omitted, depending on PostgreSQL version
        psql -h postgres -v ON_ERROR_STOP=1 -f core.sql liquid_feedback_template
        createdb -h postgres -T liquid_feedback_template liquid_feedback_template_demo
        psql -h postgres -v ON_ERROR_STOP=1 -f /opt/liquid_feedback_core/admin-party.sql liquid_feedback_template_demo
        psql -h postgres -v ON_ERROR_STOP=1 -f /opt/liquid_feedback_core/demo.sql liquid_feedback_template_demo
        createdb -h postgres -T liquid_feedback_template liquid_feedback_template_test
        psql -h postgres -v ON_ERROR_STOP=1 -f /opt/liquid_feedback_core/test.sql liquid_feedback_template_test
EOF

    echo "******CREATING DATBASE FROM TEMPLATE******"
    if [[ $demo_data == 1 ]]; then
        sudo -u www-data /bin/bash <<- EOF
            createdb -h postgres -T liquid_feedback_template_demo liquid_feedback
EOF
    elif [[ $test_data == 1 ]]; then
        sudo -u www-data /bin/bash <<- EOF
            createdb -h postgres -T liquid_feedback_template_test liquid_feedback
EOF
    else
        sudo -u www-data /bin/bash <<- EOF
            createdb -h postgres -T liquid_feedback_template liquid_feedback
EOF
    fi
  
fi

# The loop

PIDFILE="/var/run/lf_updated.pid"
PID=$$

if [ -f "${PIDFILE}" ] && kill -CONT $( cat "${PIDFILE}" ); then
  echo "lf_updated is already running."
  exit 1
fi

