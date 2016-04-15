#!/bin/bash

bootstrap=0
demo_data=0

while [ "$1" != "" ]; do
    case $1 in
        bootstrap )             bootstrap=1
                                ;;
        -d | --demo-data )      demo_data=1
                                ;;
    esac
    shift
done

if [[ $bootstrap == 1 ]]; then
    bootstrap_args=""
    if [[ "$demo_data" == "1" ]]; then
        bootstrap_args=" --demo-data"
    fi
    echo "****** running bootstrap ******"
    /opt/liquid_feedback_docker/bootstrap.sh $bootstrap_args
    exit
fi


PIDFILE="/var/run/lf_updated.pid"
PID=$$

if [ -f "${PIDFILE}" ] && kill -CONT $( cat "${PIDFILE}" ); then
  echo "lf_updated is already running."
  exit 1
fi

keep_running=true
trap "keep_running=false; echo 'SIGTERM caught in core'" SIGTERM

echo "${PID}" > "${PIDFILE}"
echo "******Starting core jobs******"
while $keeprunning; do
  su - www-data -s /bin/sh -c 'nice /opt/liquid_feedback_core/lf_update host=postgres dbname=liquid_feedback 2>&1 | logger -t "lf_updated"'
  su - www-data -s /bin/sh -c 'nice /opt/liquid_feedback_core/lf_update_issue_order host=postgres dbname=liquid_feedback 2>&1 | logger -t "lf_updated"'
  su - www-data -s /bin/sh -c 'nice /opt/liquid_feedback_core/lf_update_suggestion_order host=postgres dbname=liquid_feedback 2>&1 | logger -t "lf_updated"'
  sleep 5
done
rm "${PIDFILE}"
