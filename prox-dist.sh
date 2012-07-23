#!/usr/bin/env bash
set -e
#set -x
# Import functions from library.
source lib/functions.sh

CONFIG_FILE=$1
DIR=$( cd "$( dirname "$0" )" && pwd )
SCRIPTS="$DIR"/scripts

[ $# -eq 0 ] && {
	echo "Usage: $0 config-filename"
	echo "Example: ./prox-dist.sh conf/lfs-7.1-tools.cfg"
       	exit 1;
}

# Setup the build environment and export shell variables.
setup_environment "$DIR"

# Create LFS directories
mkdir -pv "$LFS"/{tmp/tools,usr/src/sources}
SOURCES="$LFS"/usr/src/sources

# Create /tmp/tools symlink on the host system. This will point to the
# newly-created directory on the LFS partition.
if [ ! -L /tmp/tools ]; then
	echo "Creating /tmp/tools link"
	ln -svnf "$LFS"/tmp/tools /tmp
fi

# Read config file and start building.
o_IFS=$IFS
IFS=$'\n'
for line in `cat "$CONFIG_FILE"`; do
	IFS=$o_IFS
	export LOGDIR=""
	# Remove comments starting with '#'.
	[[ "$line" = \#* ]] && continue

	# Get the name of the script.
	script="${line##*/}"; script="${script%.sh}" 
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

