arch_binaries  := $(arch_binaries) gcc

# gcc must be moved after g77 and g++
# not all files $(PF)/include/*.h are part of gcc,
# but it becomes difficult to name all these files ...

dirs_gcc = \
	$(PF)/bin \
	$(gcc_lexec_dir) \
	$(gcc_lib_dir)/{include,include-fixed} \
	$(libdir)

files_gcc = \
	$(PF)/bin/$(DEB_TARGET_GNU_TYPE)-gcc$(pkg_ver) \
	$(gcc_lexec_dir)/collect2 \
	$(gcc_lib_dir)/{libgcc*,*.o} \
	$(gcc_lib_dir)/include-fixed/README \
	$(gcc_lib_dir)/include/{float,iso646,std*,unwind,varargs}.h \
	$(gcc_lib_dir)/include-fixed/{limits,syslimits}.h \
	$(shell for d in asm bits gnu linux; do \
		  test -e $(d)/$(gcc_lib_dir)/include/$$d \
		    && echo $(gcc_lib_dir)/include/$$d; \
		done) \
	$(shell test -e $(d)/$(gcc_lib_dir)/SYSCALLS.c.X \
	       && echo $(gcc_lib_dir)/SYSCALLS.c.X) \
	$(shell for h in {,e,p,x}mmintrin.h mm3dnow.h mm_malloc.h; do \
	         test -e $(d)/$(gcc_lib_dir)/include/$$h \
	           && echo $(gcc_lib_dir)/include/$$h; \
	       done) \


ifeq ($(DEB_TARGET_ARCH),ia64)
    files_gcc += $(gcc_lib_dir)/include/ia64intrin.h
endif

ifeq ($(DEB_TARGET_ARCH),m68k)
    files_gcc += $(gcc_lib_dir)/include/math-68881.h
endif

ifeq ($(DEB_TARGET_ARCH),$(findstring $(DEB_TARGET_ARCH),powerpc ppc64))
    files_gcc += $(gcc_lib_dir)/include/{altivec.h,ppc-asm.h}
endif

# ----------------------------------------------------------------------
$(binary_stamp)-gcc: $(install_dependencies)
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_gcc)
	dh_installdirs -p$(p_gcc) $(dirs_gcc)

	rm -f $(d)/$(PF)/$(libdir)/libgcc_s.so
	ln -sf /$(PF)/$(DEB_TARGET_GNU_TYPE)/$(libdir)/libgcc_s.so.$(GCC_SONAME) $(d)/$(gcc_lib_dir)/libgcc_s.so

	DH_COMPAT=2 dh_movefiles -p$(p_gcc) $(files_gcc)

	debian/dh_rmemptydirs -p$(p_gcc)
	PATH=/usr/share/dpkg-cross:$$PATH dh_strip -p$(p_gcc)
	dh_compress -p$(p_gcc)
	dh_fixperms -p$(p_gcc)
	dh_shlibdeps -p$(p_gcc)
	dh_gencontrol -p$(p_gcc) -- -v$(DEB_VERSION) $(common_substvars)
	sed 's/cross-/$(DEB_TARGET_GNU_TYPE)-/g;s/-ver/$(pkg_ver)/g' < debian/gcc-cross.postinst > debian/$(p_gcc)/DEBIAN/postinst
	sed 's/cross-/$(DEB_TARGET_GNU_TYPE)-/g;s/-ver/$(pkg_ver)/g' < debian/gcc-cross.prerm > debian/$(p_gcc)/DEBIAN/prerm
	chmod 755 debian/$(p_gcc)/DEBIAN/{postinst,prerm}
	dh_installdeb -p$(p_gcc)
	dh_md5sums -p$(p_gcc)
	dh_builddeb -p$(p_gcc)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)

	: # remove empty directories, when all components are in place
	for d in `find $(d) -depth -type d -empty 2> /dev/null`; do \
	    while rmdir $$d 2> /dev/null; do d=`dirname $$d`; done; \
	done

	@echo "Listing installed files not included in any package:"
	-find $(d) ! -type d

