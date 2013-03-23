#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  prox-dist.sh
#
#         USAGE:  See prox-dist -h
#
#   DESCRIPTION:  This program is meant to be a tool for automatically building
#                 Linux From Scratch (LFS).
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Samuel Gabrielsson (samuel.gabrielsson@gmail.com)
#       COMPANY:
#       VERSION:  1.0
#       CREATED:  2013-03-13 09:00:00 IST
#      REVISION:  ---
#       CHANGES:  ---
#
#===============================================================================
# Import functions from library
source lib/functions.sh

# Run GNU getopt and check exit status
TEMP=$(getopt -o dhvc: --long debug,help,config: \
             -n $0 -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

CONFIGFILE=
while true; do
  case "$1" in
    -c | --config ) CONFIGFILE="$2"; shift 2 ;;
    -d | --debug ) set -x; shift ;;
    -h | --help ) print_usage; shift ; exit 0 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
CONFIGFILE="$1"

DIR=$( cd "$( dirname "$0" )" && pwd )

# Set the LFS variable
LFS=$DIR/lfs

# Set the TOOLS variable
TOOLS=/tmp/tools

# Choose number of CPUs when building
CPUS=4

# Setup the build environment and export shell variables
setup_environment $NR_CPUS

# Create LFS directory
mkdir -pv $LFS

# Set the SOURCES variable
SOURCES=$LFS/usr/src/sources

# Read config file and start building
o_IFS=$IFS
IFS=$'\n'
for line in `cat "$CONFIGFILE"`; do
    IFS=$o_IFS
    export LOGDIR=""
    # Remove comments starting with '#'
    [[ "$line" = \#* ]] && continue

    # Get the name of the script
    script="${line##*/}"
    # Set the log directory
    LOGDIR="$SOURCES/log/$script" && mkdir -p "$LOGDIR" || exit 1

    # Print the script
    echo "================================================================================"
    echo "Running: $(eval echo $line)"
    echo "Log dir: ${LOGDIR}"
    echo "================================================================================"

    # Run the build libraries
    source "$DIR"/lib/build.sh
    # Run the actual package build scipt
    source $(eval echo "$line")
done
IFS=$o_IFS
echo "================================================================================"
echo "Finished building"
echo "================================================================================"
