PACKAGE='binutils-2.22'

configure_commands()
{ :
	mkdir -pv ../binutils-build
	cd ../binutils-build
	CC="$LFS_TGT-gcc -B/tmp/tools/lib/" \
		AR=$LFS_TGT-ar RANLIB=$LFS_TGT-ranlib \
		../binutils-2.22/configure --prefix=/tmp/tools \
		--disable-nls --with-lib-path=/tmp/tools/lib
}

make_commands()
{ :
	cd ../binutils-build
	make
}

install_commands()
{ :
	cd ../binutils-build
	make install
	make -C ld clean
	make -C ld LIB_PATH=/usr/lib:/lib
	cp -v ld/ld-new /tmp/tools/bin
}

clean_commands()
{ :
	rm -rf ../binutils-build || exit 1
}

run_command unpack configure make install clean
