PACKAGE=''

run_commands()
{ :
	SPECS=`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/specs
	$LFS_TGT-gcc -dumpspecs | sed \
		-e 's@/lib\(64\)\?/ld@/tmp/tools&@g' \
		-e "/^\*cpp:$/{n;s,$, -isystem /tmp/tools/include,}" > $SPECS 
	echo "New specs file is: $SPECS"
	unset SPECS

	echo 'main(){}' > /tmp/dummy.c
	$LFS_TGT-gcc -B/tmp/tools/lib /tmp/dummy.c -o /tmp/a.out
	readelf -l /tmp/a.out | grep ': /tmp/tools'
}

clean_commands()
{ :
	rm -f /tmp/dummy.c /tmp/a.out
}

run_command run clean
