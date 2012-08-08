#!/bin/bash

test_pipe()
{
    for i in "${PIPESTATUS[@]}"; do
        test $i != 0 && { print_fail; exit 1 ; }
    done
    print_ok
    return 0
}

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


function run_command()
{
    local field_width=51

    while [ -n "$1" ]; do
        case "_$1" in
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

        # Function will execute commands without knowing about the pkg_srcdir.
        _plain)
            print_me $field_width "Executing plain shell commands"

            { plain_commands 3>&1 1>&2 2>&3 | tee "$LOGDIR/run.err" ;} &>"$LOGDIR/run.log"
            test_pipe
        ;;

        _unpack)
            print_me $field_width "Unpacking"

            unpack_commands
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
