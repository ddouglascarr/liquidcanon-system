#!/bin/bash

HELP_TEXT="
Core utility commands

Usage:
  core.sh db <command> [options]

Commands:
  shell                       Open a psql shell
  clean                       Drop database, and re-instantiate it from template
  run-file <filename>         Execute a sql file from sql directory (omit .sql)
  time-warp <interval>        Move all events back by interval
  list-members                List all the member names
  init                        Initialize the database

Environment Variables:
  LQD_DB_PORT                Database port (default 5432)
  LQD_DB_HOST                Dabatabase host (default localhost)
  LQD_DB_CONTAINER_HOST      Database host from container (default postgres)
  LQD_DB_USER                Database username (devault www-data)
  LQD_DB_SUPERUSER           Database superuser username (default postgres)
  LQD_DB_NAME                Database name (default liquid_feedback)
  LQD_DB_TEMPLATE            Database template (default liquid_feedback_template)
  API_SRC_LOCATION           Location of the api src dir (default ../liquidcanon)

"

# Init environment variables
db_port="${LQD_DB_PORT:-5432}"
db_host="${LQD_DB_HOST:-localhost}"
db_container_host="${LQD_DB_CONTAINER_HOST:-postgres}"
db_user="${LQD_DB_USER:-www-data}"
db_superuser="${LQD_DB_SUPERUSER:-postgres}"
db_name="${LQD_DB_NAME:-liquid_feedback}"
db_template="${LQD_DB_TEMPLATE:-liquid_feedback_template}"
api_src_location="${API_SRC_LOCATION:-../liquidcanon}"
ON_ERROR_ROLLBACK="${ON_ERROR_ROLLBACK:-1}"

LQD_CMD="./bin/lqd.sh"
EXEC_CMD="$LQD_CMD sys exec core_init"
PSQL_CMD="psql -p $db_port -h $db_host -U $db_user -d $db_name"

function init_db {
  $LQD_CMD sys stop
  $LQD_CMD sys up -d postgres core_init
  echo "****** connecting to database ******"
  while ! $EXEC_CMD psql -U $db_superuser -h $db_container_host -p $db_port -c \\conninfo; do 
    echo "connecting ..."; 
  done
  echo "****** connected *******"

  echo "*******CREATING TEMPLATE DATABASES*******"
  $EXEC_CMD createuser -U $db_superuser -h $db_container_host --no-superuser \
     --createdb --no-createrole www-data
  $EXEC_CMD dropdb -e -p $db_port -h $db_container_host -U $db_user $db_template
  $EXEC_CMD createdb -U $db_user -h $db_container_host -p $db_port $db_template
#  createlang -h $db_host plpgsql $db_template  # command may be omitted, depending on PostgreSQL version
  $EXEC_CMD psql -h $db_container_host -p $db_port -U $db_user -v ON_ERROR_STOP=1 -f /opt/liquid_feedback_core/core.sql $db_template

  echo "******CREATING DATBASE FROM TEMPLATE******"
  # createdb -h $db_host -U $db_user -T $db_template $db_name
  clean_db
  $LQD_CMD sys stop
  $LQD_CMD sys rm -vf core_init
}

function time_warp {
  exec_sql "SELECT time_warp_test('$@');"
  exit 0
}

function list_members {
  exec_sql "SELECT id, login FROM member ORDER BY id;"
}

function exec_sql {
  $PSQL_CMD <<EOF
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    $@;
    END;
EOF
}
function run_sql_file {
  $PSQL_CMD -f $api_src_location/src/test/resources/sql/$@.sql
}

function clean_db {
  dropdb -e -i -p $db_port -h $db_host -U $db_user $db_name
  createdb -e -h $db_host -p $db_port -U $db_user -T $db_template $db_name
}


while [ "$1" != "" ]; do
  case $1 in 

    help | -h | --help )    echo "$HELP_TEXT"
                            exit 0;
                            ;;
    "time-warp" )           shift
                            time_warp $@
                            exit
                            ;;
    "run-file" )            shift
                            run_sql_file $@
                            exit
                            ;;
    "list-members" )        shift
                            list_members
                            exit
                            ;;
    "shell" )               $PSQL_CMD
                            exit
                            ;;
    "clean" )               clean_db
                            exit
                            ;;
    "init" )                shift
                            init_db
                            exit
                            ;;
    * )                     echo "command not given, see --help"
                            exit 1;
                            ;;
  esac
  shift
done

echo "$HELP_TEXT"
exit 1
