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
#          BUGS:  path to env is different in chroot
#                 path to binaries will not work in chroot env
#         NOTES:  ---
#        AUTHOR:  Samuel Gabrielsson (samuel.gabrielsson@gmail.com)
#       COMPANY:
#       VERSION:  1.0
#       CREATED:  2013-03-13 09:00:00 IST
#      REVISION:  ---
#       CHANGES:  ---
#
#===============================================================================

#===============================================================================
# Global variables (immutable)
#===============================================================================
# Set the program file name
readonly PROGNAME=$(basename $0)

# Set the program directory path
readonly PROGDIR=$(readlink -m $(dirname $0))
#readonly PROGDIR=$( cd "$( dirname "$0" )" && pwd )

# Save all the program arguments
readonly ARGS="$@"

# Set the LFS variable
LFS=${PROGDIR}/lfs

TOOLS=/tmp/tools                            # Set the TOOLS variable
SOURCES=$LFS/usr/src/sources                # Set the SOURCES variable
LOGDIR=""                                   # Set the LOGDIR dynamically

recipe_list=                                # Init list of recipes to zero
recipe_file=                                # Init build recipe to zero
env_chroot="false"                          # Default is not to print chroot env
env_toolchain="false"                       # Default is not to build toolchain
recipe_file_defined="false"

source lib/functions.sh                     # Import functions from library
source lib/build.sh                         # Import the build functions

handle_arguments $PROGNAME $ARGS

while getopts ':def:ht-' opt; do
  case "$opt" in
    d)  set -x ;;
    e)  env_chroot="true" ;;
    f)
        if [ ! -f "$OPTARG" ]; then
            echo "$0 Error: Component file \"$OPTARG\" does not exist" >&2
            exit 1
        fi
        recipe_file_defined="true"
        recipe_file="$OPTARG"
        ;;
    h)
        print_usage $PROGNAME
        ;;
    t)
        env_toolchain="true"
        ;;
    ?)
        print_usage $PROGNAME
        echo "Error: Invalide option -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Missing option argument for -$OPTARG" >&2
        exit 1
        ;;
  esac
done

# Decrements the argument pointer so it points to next argument
shift $(($OPTIND - 1))
# $1 now refer to the first non-option item supplied on the command-line
recipe_list="$1"

if [ "$recipe_file_defined=" = "true" ] && [ ! -f "$recipe_file" ]; then
    echo "$0 Error: Component file \"$recipe_file\" does not exist" >&2
    exit 1
fi

# Check if the optional file argument has been typed
if [ "$recipe_file_defined=" = "true" ]; then
    if [ ! -f "$OPTARG" ]; then
        echo "$0 Error: Component file \"$OPTARG\" does not exist" >&2
        exit 1
    fi
fi

# Check if recipe file is not defined and that the recipe list exists
if [ ! -f "$recipe_list" ] && [ -z "$recipe_file" ]; then
    echo "$0 Error: Component list \"$recipe_list\" does not exist";
    exit 1
fi

# Create TOOLS symbolic link
if [ ! -f $TOOLS ] && [ ! -L $TOOLS ]; then
   echo "Creating symlink"
   ln -svnf $LFS$TOOLS $TOOLS
fi

# Create the LFS directory
/bin/mkdir -pv $LFS

# Setup the build environment and export shell variables
if [ "$env_toolchain" = "true" ]; then
    env_toolchain
elif [ "$env_chroot" = "true" ]; then
    env_chroot
else
    echo "Error: Choose an environment"
    exit 1
fi

# Load config file into array and remove comments and other things we don't need
recipe_array=()
if [ "$recipe_list" ]; then
    while read line; do
        recipe_array+=(${line/\#*/})
    done < "$recipe_list"
fi
# Append recipe file given from command line
recipe_array+=(${recipe_file})

# Start building
for recipe in ${recipe_array[@]}; do
    # Set the log directory
    LOGDIR="$SOURCES/log/${recipe##*/}" && /bin/mkdir -p "$LOGDIR" || exit 1

    # Print the script
    echo "================================================================================"
    echo "Running: ${recipe}"
    echo "Log dir: ${LOGDIR}"
    echo "================================================================================"

    # Run the actual package build scipt
    source $(eval echo "$recipe")
done

echo "================================================================================"
echo "Finished building"
echo "================================================================================"
