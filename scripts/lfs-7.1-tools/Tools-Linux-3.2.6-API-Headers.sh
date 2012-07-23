PACKAGE='linux-3.2.6'

configure_commands()
{ :
	make mrproper
}

check_commands()
{ :
	make headers_check
}

make_commands()
{ :
	make INSTALL_HDR_PATH=dest headers_install
}

install_commands()
{ :
	cp -rv dest/include/* /tmp/tools/include
}

run_command unpack configure check make install clean
