PACKAGE='tcl8.5.11-src'

configure_commands()
{ :
	cd unix
	./configure --prefix=/tmp/tools
}

make_commands()
{ :
	cd unix
	make
}

check_commands()
{ :
	cd unix
	TZ=UTC make test
}

install_commands()
{ :
	cd unix
	make install
	chmod -v u+w /tmp/tools/lib/libtcl8.5.so
	make install-private-headers
	ln -sfv tclsh8.5 /tmp/tools/bin/tclsh
}

run_command unpack configure make check install clean
