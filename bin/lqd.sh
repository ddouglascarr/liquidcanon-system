#!/bin/bash

# Can be called from anywhere, will run from base dir of repo.
WORKDIR=`dirname "$(readlink -f "$0")"`
cd $WORKDIR
cd ../

HELP_TEXT="
Core utility commands

Usage:
  core.sh <group> <command> [options]

Commands:
  db              Database commands (core.sh db.help for information)
  system          Manage containers

"

while [ "$1" != "" ]; do
  case $1 in 

    "db" )                      shift
                                exec ./bin/subcommands/db.sh $@
                                exit
                                ;;
    "system" | "sys" )          shift
                                exec ./bin/subcommands/system.sh $@
                                ;;
    help | --help | -h )        echo "$HELP_TEXT"
                                exit 0;
                                ;;
    * )                         echo "command not found see --help"
                                exit 1;
                                ;;
  esac
  shift
done

# No command given
echo "$HELP_TEXT"
exit 0
