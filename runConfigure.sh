#!/bin/sh

CWD=`pwd`

# create the Work subtree where we'll actually build stuff

test -d Work || mkdir Work
cd Work

# defaults in case we don't find a teTeX installation
PREFIX=/usr/local/teTeX
DATADIR=/usr/local/teTeX/share

# try to figure out where the user's teTeX is, and complain if we can't find it...
KPSEWHICH=`which kpsewhich`
if [ ! -e "${KPSEWHICH}" ]; then
	echo "### No kpsewhich found -- are you sure you have teTeX installed?"
else
	PREFIX=`echo ${KPSEWHICH} | sed -e 's!/bin/.*!/!;'`
	HYPHEN=`kpsewhich hyphen.tex`
	if [ "${HYPHEN}x" == "x" ]; then
		echo "### hyphen.tex not found -- are you sure you have teTeX installed?"
	else
		DATADIR=`echo ${HYPHEN} | sed -e 's!/texmf.*!/!;'`
	fi
fi


# run the TeX Live configure script
echo "### running TeX Live configure script as:"
echo "../configure --prefix=${PREFIX} --datadir=${DATADIR}"
../configure --prefix=${PREFIX} --datadir=${DATADIR}

# we need different configure options for ICU
echo "### configuring the ICU library"
mkdir -p libs/icu-xetex
(
	cd libs/icu-xetex
	../../../libs/icu-xetex/configure --enable-static --disable-shared
	if [ "`uname`" == "Darwin" ]; then
		# hack the resulting ICU platform.h file to claim that nl_langinfo() is not available - hoping for 10.2 compatibility :)
		perl -pi.bak -e 's/(define\s+U_HAVE_NL_LANGINFO(?:_CODESET)?\s+)1/$10/;' common/unicode/platform.h
	fi
)

# also configure TECkit separately for now
echo "### configuring the TECkit library"
mkdir -p libs/teckit
(
	cd libs/teckit
	../../../libs/teckit/configure
)

# To build:
# "make xetex" in Work/texk/web2c
# on Mac OS X only: "make xdv2pdf" in Work/texk/xdv2pdf
