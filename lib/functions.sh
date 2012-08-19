# Function will setup a good working environment.
# ARGS: CPUS
function setup_environment()
{
    # Unset each variable and only keep the necessary ones.
    unset $(/usr/bin/env | egrep '^(\w+)=(.*)$' | \
        egrep -vw 'HOME|TERM|PATH|PWD|SHLVL|_' | /usr/bin/cut -d= -f1);

    set +h
    umask 022

    LC_ALL=POSIX
    LFS_TGT=$(uname -m)-proximus-linux-gnu
    PATH=$LFS$TOOLS/bin:/bin:/usr/bin
    PS1='\u:\w\$ '
    MAKEFLAGS="-j $CPUS"

    export LFS TOOLS LC_ALL LFS_TGT PATH PS1 MAKEFLAGS
}

# Function with customized print.
function print_me()
{
    printf "$(date +"%F-%T") %-*s %s" "$1" "$2"
}

# Function will print ok in color.
function print_ok()
{
    printf '%b\n' "\e[1;32m[  OK  ]\e[m"
}

# Function will print fail in color.
function print_fail()
{
    printf '%b\n' "\e[1;31m[ FAIL ]\e[m"
    echo "================================================================================"
    echo "Dumping debug environement"
    echo "================================================================================"
    env

    echo "================================================================================"
    echo "Dumping debug error logs"
    echo "================================================================================"
    tail -n 10 $LOGDIR/*.err
}
