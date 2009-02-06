arch_binaries  := $(arch_binaries) cxx

dirs_cxx = \
	$(PF)/bin \
	$(gcc_lib_dir)

files_cxx = \
	$(PF)/bin/$(DEB_TARGET_GNU_TYPE)-g++$(pkg_ver) \
	$(gcc_lib_dir)/cc1plus

# ----------------------------------------------------------------------
$(binary_stamp)-cxx: $(install_stamp)
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_cxx)
	dh_installdirs -p$(p_cxx) $(dirs_cxx)
	DH_COMPAT=2 dh_movefiles -p$(p_cxx) $(files_cxx)

	debian/dh_rmemptydirs -p$(p_cxx)

	dh_strip -p$(p_cxx)
	dh_compress -p$(p_cxx)
	dh_fixperms -p$(p_cxx)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_shlibdeps -p$(p_cxx)
	dh_gencontrol -p$(p_cxx) -- -v$(DEB_VERSION) $(common_substvars)
	dh_installdeb -p$(p_cxx)
	sed 's/cross-/$(DEB_TARGET_GNU_TYPE)-/g;s/-ver/$(pkg_ver)/g;s/gcc/g++/g' < debian/gcc-cross.postinst > debian/$(p_cxx)/DEBIAN/postinst
	sed 's/cross-/$(DEB_TARGET_GNU_TYPE)-/g;s/-ver/$(pkg_ver)/g;s/gcc/g++/g' < debian/gcc-cross.prerm > debian/$(p_cxx)/DEBIAN/prerm
	chmod 755 debian/$(p_cxx)/DEBIAN/{postinst,prerm}
	dh_md5sums -p$(p_cxx)
	dh_builddeb -p$(p_cxx)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)
