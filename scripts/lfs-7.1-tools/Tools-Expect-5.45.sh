PACKAGE='expect5.45'

configure_commands()
{ :
	cp -v configure{,.orig}
	sed 's:/usr/local/bin:/bin:' configure.orig > configure
	./configure --prefix=/tmp/tools --with-tcl=/tmp/tools/lib \
		    --with-tclinclude=/tmp/tools/include
}

make_commands()
{ :
	make
}

check_commands()
{ :
	make test
}

install_commands()
{ :
	make SCRIPTS="" install
}

run_command unpack configure make check install clean
