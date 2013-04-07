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
#                 1. Parse arguments from command line.
#                 2. Load...
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

# Check if user has typed any arguments
if [ $# -eq 0 ]; then
    print_usage; exit 1
fi

# Run GNU getopt and check exit status
temp_args=$(getopt -o c:dhv --long component:,debug,help,verbose \
             -n $0 -- "$@")
if [ $? != 0 ] ; then echo "Terminating" >&2 ; exit 1 ; fi
eval set -- "$temp_args"

component_list=
component_file=
verbose_mode=false
while true; do
  case "$1" in
    -c | --component )
        if [ ! -f "$2" ]; then
            echo "Error: Component file \"$2\" does not exist"; exit 1
        fi
        component_file="$2"
        shift 2 ;;
    -d | --debug )
        set -x
        shift ;;
    -h | --help )
        print_usage
        shift ; exit 0 ;;
    -v | --verbose )
        verbose_mode=true
        shift ;;
    -- )
        component_list="$2"
        shift 2; break ;;
    * ) break ;;
  esac
done
# Check if component file is not defined and that the component list exists
if [ ! -f "$component_list" ] && [ -z "$component_file" ]; then
    echo "Error: Component list \"$component_list\" does not exist"; exit 1
fi

DIR=$( cd "$( dirname "$0" )" && pwd )

# Set the LFS variable
LFS=$DIR/lfs

# Set the TOOLS variable
TOOLS=/tmp/tools

# Choose number of CPUs when building
CPUS=4

# Setup the build environment and export shell variables
setup_environment

# Create LFS directory
mkdir -pv $LFS

# Set the SOURCES variable
SOURCES=$LFS/usr/src/sources

# Load config file into array and remove comments and other things we don't need
component_array=()
while read line; do
    component_array+=(${line/\#*/})
done < "$component_list"
# Append component file given from command line
component_array+=(${component_file})

# Start building
for component in ${component_array[@]}; do
    export LOGDIR=""

    # Set the log directory
    LOGDIR="$SOURCES/log/${component##*/}" && mkdir -p "$LOGDIR" || exit 1

    # Print the script
    echo "================================================================================"
    echo "Running: ${component}"
    echo "Log dir: ${LOGDIR}"
    echo "================================================================================"

    # Run the build libraries
    source "$DIR"/lib/build.sh
    # Run the actual package build scipt
    source $(eval echo "$component")
done

echo "================================================================================"
echo "Finished building"
echo "================================================================================"
