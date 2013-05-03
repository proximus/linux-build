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
component_list=
component_file=
TOOLCHAIN="false"

# Import functions from library
source lib/functions.sh

# Check if user has typed any arguments
if [ $# -eq 0 ]; then
    print_usage; exit 1
fi

# Run GNU getopt and check exit status
temp_args=$(getopt -o c:dht --long component:,debug,help,toolchain \
             -n $0 -- "$@")
if [ $? != 0 ] ; then echo "$0 Terminating" >&2 ; exit 1 ; fi
eval set -- "$temp_args"

while true; do
  case "$1" in
    -c | --component )
        if [ ! -f "$2" ]; then
            echo "$0 Error: Component file \"$2\" does not exist"; exit 1
        fi
        component_file="$2"
        shift 2 ;;
    -d | --debug )
        set -x
        shift ;;
    -h | --help )
        print_usage
        shift ; exit 0 ;;
    -t | --toolchain )
        TOOLCHAIN="true"
        shift ;;
    -- )
        component_list="$2"
        shift 2; break ;;
    * ) break ;;
  esac
done
# Check if component file is not defined and that the component list exists
if [ ! -f "$component_list" ] && [ -z "$component_file" ]; then
    echo "$0 Error: Component list \"$component_list\" does not exist"; exit 1
fi

DIR=$( cd "$( dirname "$0" )" && pwd )

# Set the LFS variable
LFS=$DIR/lfs

# Set the TOOLS variable
TOOLS=/tmp/tools
if [ ! -f $TOOLS ] && [ ! -L $TOOLS ]; then
   echo "Creating symlink"
   ln -svnf $LFS$TOOLS $TOOLS
fi

# Setup the build environment and export shell variables
if [ "$TOOLCHAIN" = "true" ]; then
    env_toolchain
else
    # Chroot environment
    if [ "$UID" -ne 0 ]; then
        echo "$0 Error: You must be root to run this script"; exit 1
    fi
    env_chroot
fi

# Create LFS directory
mkdir -pv $LFS

# Set the SOURCES variable
SOURCES=$LFS/usr/src/sources

# Source the build functions
source "$DIR"/lib/build.sh

# Load config file into array and remove comments and other things we don't need
component_array=()
if [ "$component_list" ]; then
    while read line; do
        component_array+=(${line/\#*/})
    done < "$component_list"
fi
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

    # Run the actual package build scipt
    source $(eval echo "$component")
done

echo "================================================================================"
echo "Finished building"
echo "================================================================================"
