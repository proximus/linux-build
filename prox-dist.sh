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
DIR=$( cd "$( dirname "$0" )" && pwd )      # Set the DIR directory
LFS=$DIR/lfs                                # Set the LFS variable
TOOLS=/tmp/tools                            # Set the TOOLS variable
SOURCES=$LFS/usr/src/sources                # Set the SOURCES variable
LOGDIR=""                                   # Set the LOGDIR dynamically

component_list=                             # Init list of components to zero
component_file=                             # Init build component to zero
toolchain="false"

source lib/functions.sh                     # Import functions from library
source lib/build.sh                         # Import the build functions

# Check if user has typed any arguments
if [ $# -eq 0 ]; then
    print_usage; exit 1
fi

# Run GNU getopt and check exit status
temp_args=$(getopt -o c:dhpt --long component-file:,debug,help,print-chroot,toolchain \
             -n $0 -- "$@")
if [ $? != 0 ] ; then echo "$0 Terminating" >&2 ; exit 1 ; fi
eval set -- "$temp_args"

while true; do
  case "$1" in
    -c | --component-file )
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
    -p | --print-chroot )
        env_chroot; exit 0
        shift ;;
    -t | --toolchain )
        toolchain="true"
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

# Create TOOLS symbolic link
if [ ! -f $TOOLS ] && [ ! -L $TOOLS ]; then
   echo "Creating symlink"
   ln -svnf $LFS$TOOLS $TOOLS
fi

# Create the LFS directory
/bin/mkdir -pv $LFS

# Setup the build environment and export shell variables
if [ "$toolchain" = "true" ]; then
    env_toolchain
else
    echo "Error: Choose an environment"; exit 1
fi

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
    # Set the log directory
    LOGDIR="$SOURCES/log/${component##*/}" && /bin/mkdir -p "$LOGDIR" || exit 1

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
