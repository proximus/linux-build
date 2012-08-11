#!/usr/bin/env bash
set -e
#set -x
# Import functions from library
source lib/functions.sh

CONFIG_FILE=$1
DIR=$( cd "$( dirname "$0" )" && pwd )

[ $# -eq 0 ] && {
    echo "Example:"
    echo "$0 conf/lfs-7.1-tools.cfg"
    exit 1;
}

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
for line in `cat "$CONFIG_FILE"`; do
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
