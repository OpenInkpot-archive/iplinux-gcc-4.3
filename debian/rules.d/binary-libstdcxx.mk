ifeq ($(with_libcxx),yes)
  arch_binaries  := $(arch_binaries) libstdcxx
endif

ifeq ($(with_cxxdev),yes)
  arch_binaries  := $(arch_binaries) libstdcxx-dev
  indep_binaries := $(indep_binaries)
endif

libstdc_ext = -$(BASE_VERSION)

p_lib	= libstdc++$(CXX_SONAME)
p_dev	= libstdc++$(CXX_SONAME)$(libstdc_ext)-dev
p_dbg	= libstdc++$(CXX_SONAME)$(libstdc_ext)-dbg

d_lib	= debian/$(p_lib)
d_dev	= debian/$(p_dev)
d_dbg	= debian/$(p_dbg)

dirs_dev = \
	$(PF)/$(libdir) \
	$(gcc_lib_dir)/include \
	$(PF)/include/c++/$(GCC_VERSION)

files_dev = \
	$(PF)/include/c++/$(GCC_VERSION)/ \
	$(gcc_lib_dir)/libstdc++.{a,so} \
	$(gcc_lib_dir)/libsupc++.a

dirs_dbg = \
	$(PF)/$(libdir)/debug
files_dbg = \
	$(PF)/$(libdir)/debug/libstdc++.{a,so*}

# ----------------------------------------------------------------------

gxx_baseline_dir = $(shell \
			sed -n '/^baseline_dir *=/s,.*= *\(.*\)\$$.*$$,\1,p' \
			    $(buildlibdir)/libstdc++-v3/testsuite/Makefile)
gxx_baseline_file = $(gxx_baseline_dir)/baseline_symbols.txt

# ----------------------------------------------------------------------
$(binary_stamp)-libstdcxx: $(install_stamp)
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_lib)
	dh_installdirs -p$(p_lib) $(PF)/$(libdir)

	cp -a $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/lib/libstdc++.so.* \
		$(d_lib)/$(PF)/$(libdir)/

	debian/dh_rmemptydirs -p$(p_lib)

	dh_strip -p$(p_lib)
	dh_compress -p$(p_lib)
	dh_fixperms -p$(p_lib)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_makeshlibs -p$(p_lib) \
		 -V '$(p_lib) (>= $(DEB_STDCXX_SOVERSION))'
	cat debian/$(p_lib)/DEBIAN/shlibs >> debian/shlibs.local
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_shlibdeps \
		-L$(p_lgcc) -l:$(d)/$(PF)/lib:$(d_lgcc)/lib:\
		-p$(p_lib)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_gencontrol -p$(p_lib) -- -v$(DEB_VERSION) $(common_substvars)

	dh_installdeb -p$(p_lib)
	dh_md5sums -p$(p_lib)
	dh_builddeb -p$(p_lib)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)

# ----------------------------------------------------------------------
libcxxdev_deps = $(install_stamp)
ifeq ($(with_libcxx),yes)
  libcxxdev_deps += $(binary_stamp)-libstdcxx
endif
$(binary_stamp)-libstdcxx-dev: $(libcxxdev_deps)
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_dev)
	dh_installdirs -p$(p_dev) $(dirs_dev)
	dh_installdirs -p$(p_dbg) $(dirs_dbg)

	: # - correct libstdc++-v3 file locations
	mv $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/lib/libsupc++.a $(d)/$(gcc_lib_dir)/
	mv $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/lib/libstdc++.{a,so} $(d)/$(gcc_lib_dir)/
	ln -sf ../../../libstdc++.so.$(CXX_SONAME) \
		$(d)/$(gcc_lib_dir)/libstdc++.so

	mkdir -p $(d)/$(PF)/include
	mv $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/include/c++ $(d)/$(PF)/include

	mv $(d)/$(PF)/$(DEB_TARGET_GNU_TYPE)/lib/debug $(d)/$(PF)/lib

	: # remove precompiled headers
	-find $(d) -type d -name '*.gch' | xargs rm -rf

	for i in $(d)/$(PF)/include/c++/$(GCC_VERSION)/*-linux; do \
	  if [ -d $$i ]; then mv $$i $$i-gnu; fi; \
	done

	DH_COMPAT=2 dh_movefiles -p$(p_dev) $(files_dev)
ifeq ($(with_debug),yes)
	DH_COMPAT=2 dh_movefiles -p$(p_dbg) $(files_dbg)
endif

	dh_link -p$(p_dev) \
		/$(PF)/$(libdir)/libstdc++.so.$(CXX_SONAME) \
		/$(gcc_lib_dir)/libstdc++.so

	dh_strip -p$(p_dev) --dbg-package=$(p_dbg)

ifeq ($(with_cxxdev),yes)
	debian/dh_rmemptydirs -p$(p_dev)
	debian/dh_rmemptydirs -p$(p_dbg)
endif

	dh_compress -p$(p_dev) -p$(p_dbg) -X.txt
	dh_fixperms -p$(p_dev) -p$(p_dbg)
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_shlibdeps -p$(p_dev) -p$(p_dbg) -Xlib32/debug
	DEB_HOST_ARCH=$(DEB_TARGET_ARCH) dh_gencontrol -p$(p_dev) -p$(p_dbg) \
		-- -v$(DEB_VERSION) $(common_substvars)

	dh_installdeb -p$(p_dev) -p$(p_dbg)
	dh_md5sums -p$(p_dev) -p$(p_dbg)
	dh_builddeb -p$(p_dev) -p$(p_dbg)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)
