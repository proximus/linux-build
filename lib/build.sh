#!/bin/bash
# Copyright (c) 2000-2006 Matthias S. Benkmann <article AT winterdrache DOT de>
# You may do everything with this code except misrepresent its origin.
# PROVIDED `AS IS' WITH ABSOLUTELY NO WARRANTY OF ANY KIND!

# This script will build a package based on the commands in $HOME/build.conf
# It can be called with the following parameters that
# will cause it to execute the respective *_commands() functions. If it is
# called with no parameter, that is equivalent to
# build unpack patch configure make check install clean
#
# It will create 8 log files in the $HOME directory:
#   configure.log: All messages output during configure
#   configure.err: Just the errors output during configure
#   check.log: All messages output during checking
#   check.err: Just the errors output during checking
#   make.log: All messages output during make
#   make.err: Just the errors output during make
#   install.log: All messages output during make install
#   install.err: Just the errors output during make install
#
# After running the script you should check the *.err files to see
# if any problems have occurred. If that is the case, use the corresponding
# *.log files to see the error messages in context.

if [ "_$(whoami)" != _root ]; then
  export PACKAGE_OWNER="$(whoami)"
fi

# This function auto-extracts tarballs based on PATTERNS (see build.conf) inside
# the directory $HOME/xxxbuild and
# cds into the fist directory created by the first tarball. This is also
# stored in the variable $pkg_srcdir.
unpack_commands()
{ :
  export pkg_srcdir=""
  cd "$SOURCES" || return 1
  
  for p in $PACKAGE; do
    for archive in "$SOURCES"/*"$p"* ; do
      dir=""
      if [ -f "$archive" ]; then
        case z"$archive" in
          z*.tar.bz2) dir=$(tar tjf "$archive" | grep / | head -n 1) ; tar xjf "$archive"  ;;
          z*.tar.gz)  dir=$(tar tzf "$archive" | grep / | head -n 1) ; tar xzf "$archive"  ;;
          z*.tar.xz)  dir=$(tar tJf "$archive" | grep / | head -n 1) ; tar xJf "$archive"  ;;
        esac
      fi
      dir=${dir##./}
      test -z "$dir" && echo 1>&2 "Error extracting $archive"
      test -z "$pkg_srcdir" && pkg_srcdir=${dir%%/*}
    done
  done
  
  test -z "$pkg_srcdir" && { echo 1>&2 "Source directory not found" ; return 1 ; }
  ln -snf "$pkg_srcdir" latest
}

test_pipe()
{
  for i in "${PIPESTATUS[@]}"; do
    test $i != 0 && { print_fail; exit 1 ; }
  done
  print_ok
  return 0
}

if [ $# -eq 0 ]; then
  set -- unpack patch configure make check root_pre_install install root_post_install clean
fi

function run_command()
{
local field_width=51
while [ -n "$1" ]; do
  case "_$1" in
    _all)
        shift 1
        set -- dummy unpack patch configure make check root_pre_install install root_post_install clean "$@"
        ;;

    _check)
        cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
	print_me $field_width "Checking"

        { check_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/check.err" ;} &>"$LOGDIR/check.log"
        test_pipe
        ;;

    _clean)
	print_me $field_width "Cleaning"
	# Check if function is defined and then run it.
	if [ "`type -t clean_commands`" = 'function' ]; then
          clean_commands
	fi

	if [[ -h "$SOURCES/latest" && -n "$pkg_srcdir" ]]; then
            cd "$SOURCES/latest"
  	    rm -rf "$(readlink -nf $pkg_srcdir)" || exit 1
  	    cd ../ && rm -rf 'latest' || exit 1
	fi
	print_ok
        ;;

    _configure)
	cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
        print_me $field_width "Configuring"

        { configure_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/configure.err" ;} &>"$LOGDIR/configure.log"
        test_pipe
        # NOTE: Simply using && instead of test_pipe would not work, because &&
        # only tests the exit status of the last command in the pipe, which is tee.
        ;;

    _install)
        cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
	print_me $field_width "Installing"

        { install_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/install.err" ;} &>"$LOGDIR/install.log"
        test_pipe
        ;;

    _make)
	cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
        print_me $field_width "Building"

        { make_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/make.err" ;} &>"$LOGDIR/make.log"
        test_pipe
        ;;

    _patch)
	cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
        print_me $field_width "Patching"

        { patch_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/patch.err" ;} &>"$LOGDIR/patch.log"
        test_pipe
        ;;

    _prepare)
        cd "$SOURCES/latest" && pkg_srcdir="$(pwd)" || exit 1
	print_me $field_width "Preparing"

        { prepare_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/prepare.err" ;} &>"$LOGDIR/prepare.log"
        test_pipe
        ;;

    _run)
        print_me $field_width "Running commands"

        { run_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/run.err" ;} &>"$LOGDIR/run.log"
        test_pipe
        ;;

    _unpack)
        print_me $field_width "Unpacking"

        unpack_commands # no logging for unpack necessary 
        test_pipe
        ;;

    *)
        echo 1>&2 "Unknown command '$1'"
        exit 1
        ;;
  esac       
  shift 1
done
}
