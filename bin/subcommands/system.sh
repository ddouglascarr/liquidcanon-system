#!/bin/bash

HELP_TEXT="
Manage the containers

Usage:
  lqd system [COMMAND] [service] [options]

Commands:
  recreate            Stop and remove all containers, re-start project
  shell               Run an interactive shell in a container
  exec                Execute a shell command in a container
  *                   Any unrecognized commands are passed to docker-compose. See docker-compose --help for details

Environment Variables:
  LQD_SYS_PREFIX      Prefix for container names (default lqd)
  LQD_SYS_ENV         System environment {dev | production} (default dev)
  "

# Init environment variables
sys_prefix="${LQD_SYS_PREFIX:-lqd}"
sys_env="${LQF_SYS_ENV:-dev}"

function print_help {
  echo "$HELP_TEXT"
  docker-compose --help
  exit 0;
}

function stop_project {
  $DOCKER_CMD stop
}

function start_project {
  if [ "$ivet_env" == "production" ]; then
    sudo systemctl start ivet.service
  else
    $DOCKER_CMD up -d
  fi
}

function rm_containers {
  $DOCKER_CMD rm -vf
}

function recreate {
  stop_project
  rm_containers
  start_project
}

function exec_shell {
  docker exec -it "$sys_prefix"_"$@"_1 /bin/bash
}

function exec_cmd {
  container_name=$1
  shift

  docker exec -it "$sys_prefix"_"$container_name"_1 $@
}

DOCKER_CMD="docker-compose -p $sys_prefix -f docker-compose.yml"


while [ "$1" != "" ]; do
  case $1 in 

    "deploy" )        shift
                      deploy $@
                      exit
                      ;;

    "recreate" )      recreate
                      exit
                      ;;

    "shell" )         shift
                      exec_shell $@
                      exit
                      ;;

    "exec" )          shift
                      exec_cmd $@
                      exit
                      ;;

    "clean" )         clean
                      exit 0 # always exit with success
                      ;;

    * )               $DOCKER_CMD $@
                      exit
                      ;;

  esac
  shift
done


