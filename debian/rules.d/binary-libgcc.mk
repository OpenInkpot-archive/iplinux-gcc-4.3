ifeq ($(with_libgcc),yes)
  arch_binaries	:= $(arch_binaries) libgcc
endif

p_lgcc		= libgcc$(GCC_SONAME)
p_lgccdbg	= libgcc$(GCC_SONAME)-dbg
d_lgcc		= debian/$(p_lgcc)
d_lgccdbg	= debian/$(p_lgccdbg)

# ----------------------------------------------------------------------
$(binary_stamp)-libgcc: $(install_dependencies)
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_lgcc) $(d_lgccdbg)
	dh_installdirs -p$(p_lgcc) $(libdir)
	dh_installdirs -p$(p_lgccdbg) $(libdir)

ifeq ($(with_shared_libgcc),yes)
	mv $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/lib/libgcc_s.so.$(GCC_SONAME) $(d_lgcc)/$(libdir)/.
endif

	dh_strip -v -p$(p_lgcc) --dbg-package=$(p_lgccdbg)
	dh_compress -p$(p_lgcc) -p$(p_lgccdbg)
	dh_fixperms -p$(p_lgcc) -p$(p_lgccdbg)
ifeq ($(with_shared_libgcc),yes)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_makeshlibs -p$(p_lgcc) \
		-V '$(p_lgcc) (>= $(DEB_LIBGCC_SOVERSION))' -- -v$(DEB_LIBGCC_VERSION)
	cat debian/$(p_lgcc)/DEBIAN/shlibs >> debian/shlibs.local
endif
	dh_shlibdeps -p$(p_lgcc)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_gencontrol -p$(p_lgcc) -p$(p_lgccdbg) \
		-- -v$(DEB_LIBGCC_VERSION) $(common_substvars)

	dh_installdeb -p$(p_lgcc) -p$(p_lgccdbg)
	dh_md5sums -p$(p_lgcc) -p$(p_lgccdbg)
	dh_builddeb -p$(p_lgcc) -p$(p_lgccdbg)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)
