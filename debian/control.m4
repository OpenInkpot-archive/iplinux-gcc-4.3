divert(-1)

define(`checkdef',`ifdef($1, , `errprint(`error: undefined macro $1
')m4exit(1)')')
define(`errexit',`errprint(`error: undefined macro `$1'
')m4exit(1)')

dnl The following macros must be defined, when called:
dnl ifdef(`SRCNAME',	, errexit(`SRCNAME'))
dnl ifdef(`PV',		, errexit(`PV'))
dnl ifdef(`ARCH',		, errexit(`ARCH'))

dnl The architecture will also be defined (-D__i386__, -D__powerpc__, etc.)

define(`PN', `$1')

define(`ifenabled', `ifelse(index(enabled_languages, `$1'), -1, `dnl', `$2')')

divert`'dnl
dnl --------------------------------------------------------------------------
Source: SRCNAME
Section: host/tools
Priority: optional
Maintainer: Mikhail Gusarov <dottedmag@dottedmag.net>
Standards-Version: 3.8.0
ifdef(`TARGET',`dnl cross
Build-Depends: dpkg-dev (>= 1.14.15), debhelper (>= 5.0.62), dpkg-cross (>= 1.25.99), LIBC_BUILD_DEP, LIBC_BIARCH_BUILD_DEP LIBUNWIND_BUILD_DEP LIBATOMIC_OPS_BUILD_DEP AUTOGEN_BUILD_DEP m4, autoconf, automake1.9, libtool, gawk, lzma, BINUTILS_BUILD_DEP, bison (>= 1:2.3), flex, realpath (>= 1.9.12), lsb-release, make (>= 3.81)
',`dnl native
Build-Depends: dpkg-dev (>= 1.14.15), debhelper (>= 5.0.62), gcc-multilib [amd64 i386 mips mipsel powerpc ppc64 s390 sparc kfreebsd-amd64], LIBC_BUILD_DEP, LIBC_BIARCH_BUILD_DEP AUTOGEN_BUILD_DEP libunwind7-dev (>= 0.98.5-6) [ia64], libatomic-ops-dev [ia64], m4, autoconf, automake1.9, libtool, gawk, CHECK_BUILD_DEP, lzma, BINUTILS_BUILD_DEP, binutils-hppa64 (>= BINUTILSV) [hppa], gperf (>= 3.0.1), bison (>= 1:2.3), flex, gettext, texinfo (>= 4.3), libmpfr-dev (>= 2.3.0), FORTRAN_BUILD_DEP locales [locale_no_archs], procps [linux_gnu_archs], sharutils, PASCAL_BUILD_DEP JAVA_BUILD_DEP GNAT_BUILD_DEP SPU_BUILD_DEP CLOOG_BUILD_DEP realpath (>= 1.9.12), chrpath, lsb-release, make (>= 3.81)
Build-Depends-Indep: LIBSTDCXX_BUILD_INDEP JAVA_BUILD_INDEP
')dnl
dnl Build-Conflicts: qt3-dev-tools

dnl default base package dependencies
define(`BASETARGET', `')
define(`BASEDEP', `gcc`'PV-base (= ${gcc:Version})')
define(`SOFTBASEDEP', `gcc`'PV-base (>= ${gcc:SoftVersion})')

dnl base, when building libgcc out of the gcj source; needed if new symbols
dnl in libgcc are used in libgcj.
ifelse(index(SRCNAME, `gcj'), 0, `
define(`BASEDEP', `gcj`'PV-base (= ${gcj:Version})')
define(`SOFTBASEDEP', `gcj`'PV-base (>= ${gcj:SoftVersion})')
')

ifdef(`TARGET', `', `
ifenabled(`gccbase',`

Package: gcc`'PV-base
Architecture: any
Section: host/tools
Priority: required
Replaces: cpp-4.3 (<< 4.3.2)
Description: The GNU Compiler Collection (base package)
 This package contains files common to all languages and libraries
 contained in the GNU Compiler Collection (GCC).
ifdef(`BASE_ONLY', `dnl
 .
 This version of GCC is not yet available for this architecture.
 Please use the compilers from the gcc-snapshot package for testing.
')`'dnl
')`'dnl
')`'dnl native

ifenabled(`gccxbase',`
dnl override default base package dependencies to cross version
dnl This creates a toolchain that doesnt depend on the system -base packages
define(`BASETARGET', `PV`'TS')
define(`BASEDEP', `gcc`'BASETARGET-base (= ${gcc:Version})')
define(`SOFTBASEDEP', `gcc`'BASETARGET-base (>= ${gcc:SoftVersion})')

Package: gcc`'BASETARGET-base
Architecture: any
Section: host/tools
Priority: required
Conflicts: gcc-3.5-base
Replaces: gcc-3.5-base
Description: The GNU Compiler Collection (base package)
 This package contains files common to all languages and libraries
 contained in the GNU Compiler Collection (GCC).
')`'dnl

ifenabled(`libgcc',`
Package: libgcc1
Architecture: any
Section: core
Priority: required
Depends: ${shlibs:Depends}
Description: GCC support library
 Shared version of the support library, a library of internal subroutines
 that GCC uses to overcome shortcomings of particular machines, or
 special needs for some languages.

Package: libgcc1-dbg
Architecture: any
Section: debug
Priority: extra
Depends: libgcc1 (= ${gcc:EpochVersion})
Description: GCC support library (debug symbols)
 Debug symbols for the GCC support library.

Package: libgcc1`'LS
Architecture: all
Section: host/cross
Priority: extra
Depends: ${shlibs:Depends}
Provides: libgcc1-TARGET-dcv1
Description: GCC support library (TARGET)
 Shared version of the support library, a library of internal subroutines
 that GCC uses to overcome shortcomings of particular machines, or
 special needs for some languages.
 .
 This package contains files for TARGET architecture, for use in cross-compile
 environment.

Package: libgcc1-dbg`'LS
Architecture: all
Section: host/cross
Priority: extra
Depends: libgcc1`'LS (= ${gcc:EpochVersion})
Description: GCC support library (debug symbols) (TARGET)
 Debug symbols for the GCC support library.
 .
 This package contains files for TARGET architecture, for use in cross-compile
 environment.

Package: libgcc2`'LS
Architecture: ifdef(`TARGET',`all',`m68k')
Section: ifdef(`TARGET',`devel',`libs')
Priority: ifdef(`TARGET',`extra',required)
Depends: BASEDEP, ${shlibs:Depends}
ifdef(`TARGET',`Provides: libgcc2-TARGET-dcv1
',`')`'dnl
Description: GCC support library`'ifdef(`TARGET',` (TARGET)', `')
 Shared version of the support library, a library of internal subroutines
 that GCC uses to overcome shortcomings of particular machines, or
 special needs for some languages.
ifdef(`TARGET', `dnl
 .
 This package contains files for TARGET architecture, for use in cross-compile
 environment.
')`'dnl

Package: libgcc2-dbg`'LS
Architecture: ifdef(`TARGET',`all',`m68k')
Section: libdevel
Priority: extra
Depends: BASEDEP, libgcc2 (= ${gcc:Version})
Description: GCC support library (debug symbols)`'ifdef(`TARGET',` (TARGET)', `')
 Debug symbols for the GCC support library.
ifdef(`TARGET', `dnl
 .
 This package contains files for TARGET architecture, for use in cross-compile
 environment.
')`'dnl
')`'dnl libgcc

ifenabled(`cdev',`
Package: gcc`'PV`'TS
Architecture: any
Section: host/tools
Priority: ifdef(`TARGET',`extra',`optional')
Depends: BASEDEP, cpp`'PV`'TS (= ${gcc:Version}), binutils`'TS (>= ${binutils:Version}), ${dep:libgcc}, ${dep:libssp}, ${dep:libgomp}, ${dep:libunwinddev}, ${shlibs:Depends}
Recommends: ${dep:libcdev}
Suggests: ${gcc:multilib}, libmudflap`'MF_SO`'PV-dev`'LS (>= ${gcc:Version}), gcc`'PV-doc (>= ${gcc:SoftVersion}), gcc`'PV-locales (>= ${gcc:SoftVersion}), libgcc`'GCC_SO-dbg`'LS, libgomp`'GOMP_SO-dbg`'LS, libmudflap`'MF_SO-dbg`'LS
Provides: c-compiler`'TS
Description: The GNU C compiler`'ifdef(`TARGET',` (cross compiler for TARGET architecture)', `')
 This is the GNU C compiler, a fairly portable optimizing compiler for C.
ifdef(`TARGET', `dnl
 .
 This package contains C cross-compiler for TARGET architecture.
')`'dnl
')`'dnl cdev

ifenabled(`cdev',`
Package: cpp`'PV`'TS
Architecture: any
Section: host/tools
Priority: optional
Depends: BASEDEP, ${shlibs:Depends}
Suggests: gcc`'PV-locales (>= ${gcc:SoftVersion})
Description: The GNU C preprocessor
 A macro processor that is used automatically by the GNU C compiler
 to transform programs before actual compilation.
 .
 This package has been separated from gcc for the benefit of those who
 require the preprocessor but not the compiler.
ifdef(`TARGET', `dnl
 .
 This package contains preprocessor configured for TARGET architecture.
')`'dnl

ifdef(`TARGET', `', `
Package: gcc`'PV-locales
Architecture: all
Section: core
Priority: optional
Depends: SOFTBASEDEP, cpp`'PV (>= ${gcc:SoftVersion})
Recommends: gcc`'PV (>= ${gcc:SoftVersion})
Description: The GNU C compiler (native language support files)
 Native language support for GCC. Lets GCC speak your language,
 if translations are available.
 .
 Please do NOT submit bug reports in other languages than "C".
 Always reset your language settings to use the "C" locales.
')`'dnl native
')`'dnl cdev

ifenabled(`c++',`
ifenabled(`c++dev',`
Package: g++`'PV`'TS
Architecture: any
Section: host/tools
Priority: optional
Depends: BASEDEP, gcc`'PV`'TS (= ${gcc:Version}), libstdc++CXX_SO`'PV-dev`'LS (= ${gcc:Version}), ${shlibs:Depends}
Provides: c++-compiler`'TS, c++abi2-dev
Suggests: ${gxx:multilib}, gcc`'PV-doc (>= ${gcc:SoftVersion}), libstdc++CXX_SO`'PV-dbg`'LS
Description: The GNU C++ compiler`'ifdef(`TARGET',` (cross compiler for TARGET architecture)', `')
 This is the GNU C++ compiler, a fairly portable optimizing compiler for C++.
ifdef(`TARGET', `dnl
 .
 This package contains C++ cross-compiler for TARGET architecture.
')`'dnl

')`'dnl c++dev
')`'dnl c++

ifenabled(`c++',`
ifenabled(`libcxx',`
Package: libstdc++CXX_SO
Architecture: any
Section: core
Priority: required
Depends: ${shlibs:Depends}
Description: The GNU Standard C++ Library v3
 This package contains an additional runtime library for C++ programs
 built with the GNU compiler.
 .
 libstdc++-v3 is a complete rewrite from the previous libstdc++-v2, which
 was included up to g++-2.95. The first version of libstdc++-v3 appeared
 in g++-3.0.

Package: libstdc++CXX_SO`'LS
Architecture: any
Section: host/cross
Priority: extra
Description:

')`'dnl libcxx

ifenabled(`c++dev',`
Package: libstdc++CXX_SO`'PV-dev
Architecture: any
Section: libdevel
Priority: optional
Depends: libstdc++CXX_SO (>= ${gcc:Version}), ${dep:libcdev}
Provides: libstdc++-dev
Description: The GNU Standard C++ Library v3 (development files)
 This package contains the headers and static library files necessary for
 building C++ programs which use libstdc++.
 .
 libstdc++-v3 is a complete rewrite from the previous libstdc++-v2, which
 was included up to g++-2.95. The first version of libstdc++-v3 appeared
 in g++-3.0.

Package: libstdc++CXX_SO`'PV-dev`'LS
Architecture: any
Section: host/cross
Priority: extra
Description:

Package: libstdc++CXX_SO`'PV-dbg
Architecture: any
Section: debug
Priority: extra
Depends: libstdc++CXX_SO (>= ${gcc:Version}), libgcc`'GCC_SO-dbg, ${shlibs:Depends}
Description: The GNU Standard C++ Library v3 (debugging files)
 This package contains the shared library of libstdc++ compiled with
 debugging symbols.

Package: libstdc++CXX_SO`'PV-dbg`'LS
Architecture: any
Section: host/cross
Priority: extra
Description:


')`'dnl c++dev
')`'dnl c++

dnl last line in file
