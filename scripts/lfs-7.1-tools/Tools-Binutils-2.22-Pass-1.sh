PACKAGE='binutils-2.22.tar'

configure_commands()
{ :
	mkdir -pv ../binutils-build
	cd ../binutils-build
	../binutils-2.22/configure \
		--target=$LFS_TGT --prefix=/tmp/tools \
		--disable-nls --disable-werror
}

make_commands()
{ :
	cd ../binutils-build
	make
	case $(uname -m) in
		x86_64) mkdir -pv /tmp/tools/lib && ln -svnf lib /tmp/tools/lib64 ;;
	esac
}

install_commands()
{ :
	cd ../binutils-build
	make install
}

clean_commands()
{ :
	rm -rf ../binutils-build || exit 1
}

run_command unpack configure make install clean
