PACKAGE=''

# Download all the packages and patches needed to build LFS.
WGET_URLS="$DIR"/scripts/wget-list-lfs-7.1

# Download all sources.
run_commands()
{ :
	# Quit if SOURCES directory does not exists
	if [ ! -d "$SOURCES" ]; then
		echo "ERROR: directory $SOURCES does not exist"; exit 1;
	fi

	# Make the SOURCES directory writable and sticky
	chmod -v a+wt "$SOURCES"

	# Download lfs packages to SOURCES directory
	wget -nc -i "$WGET_URLS" -P "$SOURCES"

	# Check if lfs packages are healthy.
	pushd  "$SOURCES"
	md5sum -c "$WGET_URLS".md5
	popd
}

run_command run
