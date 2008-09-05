arch_binaries  := $(arch_binaries) snapshot

p_snap	= gcc-snapshot
d_snap	= debian/$(p_snap)

dirs_snap = \
	$(docdir)/$(p_snap) \
	usr/lib

# ----------------------------------------------------------------------
$(binary_stamp)-snapshot: $(install_snap_stamp)
	dh_testdir
	dh_testroot
	mv $(install_snap_stamp) $(install_snap_stamp)-tmp

	rm -rf $(d_snap)
	dh_installdirs -p$(p_snap) $(dirs_snap)

	-find $(d) -name '*.gch' -type d | xargs rm -rf

	mv $(d)/$(PF) $(d_snap)/usr/lib/

	rm -rf $(d_snap)/$(PF)/lib/nof
ifeq ($(with_java),yes)
	ln -sf libgcj.so.$(GCJ_SONAME).0.0 $(d_snap)/$(PF)/lib/libgcj_bc.so.1.0.0
endif

ifeq ($(with_hppa64),yes)
	: # provide as and ld links
	dh_link -p $(p_snap) \
		/usr/bin/hppa64-linux-gnu-as \
		/$(PF)/libexec/gcc/hppa64-linux-gnu/$(GCC_VERSION)/as \
		/usr/bin/hppa64-linux-gnu-ld \
		/$(PF)/libexec/gcc/hppa64-linux-gnu/$(GCC_VERSION)/ld
endif

ifeq ($(with_check),yes)
	dh_installdocs -p$(p_snap) test-summary
  ifeq ($(with_pascal),yes)
	cp -p gpc-test-summary $(d_snap)/$(docdir)/$(p_snap)/
  endif
else
	dh_installdocs -p$(p_snap)
endif
	if [ -f $(buildlibdir)/libstdc++-v3/testsuite/current_symbols.txt ]; \
	then \
	  cp -p $(buildlibdir)/libstdc++-v3/testsuite/current_symbols.txt \
	    $(d_snap)/$(docdir)/$(p_snap)/libstdc++6_symbols.txt; \
	fi
	cp -p debian/README.snapshot \
		$(d_snap)/$(docdir)/$(p_snap)/README.Debian
	dh_installchangelogs -p$(p_snap)
ifeq ($(DEB_TARGET_ARCH),hppa)
	dh_strip -p$(p_snap) -Xdebug -X.o -X.a
else
	dh_strip -p$(p_snap) -Xdebug
endif
	dh_compress -p$(p_snap)
	-find $(d_snap) -type d ! -perm 755 -exec chmod 755 {} \;
	dh_fixperms -p$(p_snap)

	( \
	  echo 'libgcc_s $(GCC_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libobjc $(OBJC_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgfortran $(FORTRAN_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libmudflap $(MUDFLAP_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libmudflapth $(MUDFLAP_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libffi $(FFI_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgcj $(GCJ_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgcj-tools $(GCJ_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgij $(GCJ_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgcj_bc 1 gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgomp $(GOMP_SONAME) gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgnat-$(GNAT_SONAME) 1 gcc-snapshot (>= $(DEB_VERSION))'; \
	  echo 'libgnarl-$(GNAT_SONAME) 1 gcc-snapshot (>= $(DEB_VERSION))'; \
	) > debian/shlibs.local

	dh_shlibdeps -p$(p_snap) -l$(d_snap)/$(PF)/lib:$(d_snap)/$(PF)/$(if $(filter $(DEB_TARGET_ARCH),amd64 ppc64),lib32,lib64) -Xlibgcj-tools -Xlibmudflap
	-sed -i -e 's/gcc-snapshot[^,]*, //g' debian/gcc-snapshot.substvars

	dh_gencontrol -p$(p_snap) -- $(common_substvars)
	dh_installdeb -p$(p_snap)
	dh_md5sums -p$(p_snap)
	dh_builddeb -p$(p_snap)

	trap '' 1 2 3 15; touch $@; mv $(install_snap_stamp)-tmp $(install_snap_stamp)
