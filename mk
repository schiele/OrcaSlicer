#!/bin/bash
#PAR=$(nproc)
PAR=8
set -eux
cd $(dirname $0)
DIR="$PWD"
DEPFLAGS=
BLDFLAGS=
case "$*" in
	*stable*)
	       BDIR=stable
	       ;;
	*)
	       BDIR=build
	       ;;
esac
DDIR="deps/$BDIR"
case "$*" in
	*cmd*)
	       BDIR="${BDIR}cmd"
	       BLDFLAGS="$BLDFLAGS -DSLIC3R_GUI=no"
	       ;;
esac
case "$*" in
	*dyn*)
	       DDIR="${DDIR}dyn"
	       BDIR="${BDIR}dyn"
	       #DEPFLAGS="$DEPFLAGS -DPrusaSlicer_deps_PACKAGE_EXCLUDES:STRING=Boost;Cereal;CGAL;CURL;EXPAT;GLEW;GMP;JPEG;MPFR;NLopt;OCCT;OpenCSG;OpenEXR;OpenSSL;PNG;Qhull;TIFF;ZLIB"
	       DEPFLAGS="$DEPFLAGS -DDEP_BLOCKED=Cereal;EXPAT;GLEW;GMP;JPEG;MPFR;NLopt;OpenCSG;OpenEXR;PNG;Qhull;TIFF;ZLIB"
	       #BLDFLAGS="$BLDFLAGS -DFORCE_OpenCASCADE_VERSION=7.5.0 -DSLIC3R_STATIC_EXCLUDE_GLEW=1 -DBoost_USE_STATIC_LIBS=OFF -DCGAL_Boost_USE_STATIC_LIBS=OFF"
	       BLDFLAGS="$BLDFLAGS -DSLIC3R_STATIC_EXCLUDE_GLEW=1"
	       ;;
esac
case "$*" in
	*debug*)
	       BDIR="${BDIR}debug"
	       BLDFLAGS="$BLDFLAGS -DCMAKE_BUILD_TYPE=Debug"
	       STRIP=
	       ;;
       *)
	       STRIP=/strip
	       ;;
esac
case "$*" in
	*clean*) rm -rf "$DIR/$DDIR" "$DIR/$BDIR";;
esac
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
mkdir -p "$DIR/$DDIR"
cd "$DIR/$DDIR"
cmake .. $DEPFLAGS -DDEP_WX_GTK3=ON -DDEP_DOWNLOAD_DIR="$DIR/deps/download"
make -j $PAR
mkdir -p "$DIR/$BDIR"
cd "$DIR/$BDIR"
cmake .. -DSLIC3R_STATIC=1 $BLDFLAGS \
	-DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF \
	-DCMAKE_PREFIX_PATH="$DIR/$DDIR/destdir/usr/local" \
	-DCMAKE_INSTALL_PREFIX=~/tools/orcaslicer/$BDIR \
	-DBBL_RELEASE_TO_PUBLIC=1 -DBBL_INTERNAL_TESTING=0 \
	-DORCA_TOOLS=ON
make -j $PAR
make install$STRIP
