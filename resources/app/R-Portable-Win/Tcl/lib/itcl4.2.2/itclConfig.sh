# itclConfig.sh --
#
# This shell script (for sh) is generated automatically by Itcl's
# configure script.  It will create shell variables for most of
# the configuration options discovered by the configure script.
# This script is intended to be included by the configure scripts
# for Itcl extensions so that they don't have to figure this all
# out for themselves.  This file does not duplicate information
# already provided by tclConfig.sh, so you may need to use that
# file in addition to this one.
#
# The information in this file is specific to a single platform.

# Itcl's version number.
itcl_VERSION='4.2.2'
ITCL_VERSION='4.2.2'

# The name of the Itcl library (may be either a .a file or a shared library):
itcl_LIB_FILE=itcl422.dll
ITCL_LIB_FILE=itcl422.dll

# String to pass to linker to pick up the Itcl library from its
# build directory.
itcl_BUILD_LIB_SPEC='-L/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2 -litcl422'
ITCL_BUILD_LIB_SPEC='-L/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2 -litcl422'

# String to pass to linker to pick up the Itcl library from its
# installed directory.
itcl_LIB_SPEC='-L/root/Tcl/lib/itcl4.2.2 -litcl422'
ITCL_LIB_SPEC='-L/root/Tcl/lib/itcl4.2.2 -litcl422'

# The name of the Itcl stub library (a .a file):
itcl_STUB_LIB_FILE=libitclstub422.a
ITCL_STUB_LIB_FILE=libitclstub422.a

# String to pass to linker to pick up the Itcl stub library from its
# build directory.
itcl_BUILD_STUB_LIB_SPEC='-L/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2 -litclstub422'
ITCL_BUILD_STUB_LIB_SPEC='-L/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2 -litclstub422'

# String to pass to linker to pick up the Itcl stub library from its
# installed directory.
itcl_STUB_LIB_SPEC='-L/root/Tcl/lib/itcl4.2.2 -litclstub422'
ITCL_STUB_LIB_SPEC='-L/root/Tcl/lib/itcl4.2.2 -litclstub422'

# String to pass to linker to pick up the Itcl stub library from its
# build directory.
itcl_BUILD_STUB_LIB_PATH='/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2/libitclstub422.a'
ITCL_BUILD_STUB_LIB_PATH='/root/64bit/tcl8.6.12/win/pkgs/itcl4.2.2/libitclstub422.a'

# String to pass to linker to pick up the Itcl stub library from its
# installed directory.
itcl_STUB_LIB_PATH='/root/Tcl/lib/itcl4.2.2/libitclstub422.a'
ITCL_STUB_LIB_PATH='/root/Tcl/lib/itcl4.2.2/libitclstub422.a'

# Location of the top-level source directories from which [incr Tcl]
# was built.  This is the directory that contains generic, unix, etc.
# If [incr Tcl] was compiled in a different place than the directory
# containing the source files, this points to the location of the sources,
# not the location where [incr Tcl] was compiled.
itcl_SRC_DIR='/root/64bit/tcl8.6.12/pkgs/itcl4.2.2'
ITCL_SRC_DIR='/root/64bit/tcl8.6.12/pkgs/itcl4.2.2'

# String to pass to the compiler so that an extension can
# find installed Itcl headers.
itcl_INCLUDE_SPEC='-I/root/64bit/tcl8.6.12/pkgs/itcl4.2.2/generic'
ITCL_INCLUDE_SPEC='-I/root/64bit/tcl8.6.12/pkgs/itcl4.2.2/generic'
