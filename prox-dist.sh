#!/usr/bin/env bash
set -e
#set -x
# Import functions from library.
source lib/functions.sh

CONFIG_FILE=$1
DIR=$( cd "$( dirname "$0" )" && pwd )

[ $# -eq 0 ] && {
	echo "Example:"
	echo "$0 conf/lfs-7.1-tools.cfg"
       	exit 1;
}

# Setup the build environment and export shell variables.
setup_environment "$DIR"

# Create LFS directories
mkdir -pv "$LFS"/{,usr/src/sources}
SOURCES="$LFS"/usr/src/sources

# Make TOOLS variable available in build environment.
export TOOLS=/tmp/tools

# Read config file and start building.
o_IFS=$IFS
IFS=$'\n'
for line in `cat "$CONFIG_FILE"`; do
	IFS=$o_IFS
	export LOGDIR=""
	# Remove comments starting with '#'.
	[[ "$line" = \#* ]] && continue

	# Get the name of the script.
	script="${line##*/}"
	# Set the log directory.
	LOGDIR="$SOURCES"/log/"$script" && mkdir -p "$LOGDIR" || exit 1

	# Print the script.
    echo "================================================================================"
    echo "Executing: $(eval echo $line)"
    echo "Log dir: ${LOGDIR}"
    echo "================================================================================"

	# Run the build libraries.
	source "$DIR"/lib/build.sh
	# Run the actual package build scipt.
	source $(eval echo "$line")
done
IFS=$o_IFS
echo "================================================================================"
echo "Finished building."
echo "================================================================================"

