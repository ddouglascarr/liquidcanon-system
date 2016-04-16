#!/bin/bash

# Can be called from anywhere, will run from this dir.
WORKDIR=`dirname "$(readlink -f "$0")"`
cd $WORKDIR

HELP_TEXT="
Core utility commands

Usage:
  core.sh <group> <command> [options]

Commands:
  db              Database commands (core.sh db.help for information)

"

while [ "$1" != "" ]; do
  case $1 in 

    "db" )      shift
                exec ./subcommands/db.sh $@
                exit
                ;;
    help | --help | -h )        echo "$HELP_TEXT"
                exit 0;
                ;;
    * )         echo "command not found see --help"
                exit 1;
                ;;
  esac
  shift
done

# No command given
echo "$HELP_TEXT"
exit 0
