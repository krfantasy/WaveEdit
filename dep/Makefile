
LOCAL = $(PWD)

include ../Makefile-arch.inc
ifeq ($(ARCH),mac)
	export CFLAGS = \
		-mmacosx-version-min=11.0 \
		-arch x86_64 -arch arm64
	export CXXFLAGS = $(CFLAGS)
	export LDFLAGS = $(CFLAGS)
endif

sdl2_version := 2.26.3
jansson_version := 2.14
libsndfile_version := 1.2.0
libsamplerate_version := 0.2.2
libcurl_version := 7.88.1

sdl2 := SDL2-$(sdl2_version)
jansson := jansson-$(jansson_version)
libsndfile := libsndfile-$(libsndfile_version)
libsamplerate := libsamplerate-$(libsamplerate_version)
libcurl := curl-$(libcurl_version)

# This instance of make should be serialized, but -j flags are passed down to each recursive Makefile
.NOTPARALLEL:

all: $(sdl2) $(jansson) $(libsndfile) $(libsamplerate) $(libcurl)

$(sdl2):
	wget -nc https://github.com/libsdl-org/SDL/releases/download/release-$(sdl2_version)/$@.tar.gz
	tar xf $@.tar.gz
	cd $@ && ./configure --prefix="$(LOCAL)" --enable-input-tslib=no
	$(MAKE) -C $@
	$(MAKE) -C $@ install

$(jansson):
	wget -nc https://github.com/akheron/jansson/releases/download/v$(jansson_version)/$@.tar.gz
	tar xf $@.tar.gz
	cd $@ && ./configure --prefix="$(LOCAL)"
	$(MAKE) -C $@
	$(MAKE) -C $@ install

$(libsndfile):
	wget -nc https://github.com/libsndfile/libsndfile/releases/download/$(libsndfile_version)/$@.tar.xz
	tar xf $@.tar.xz
	cd $@ && ./configure --prefix="$(LOCAL)"
	$(MAKE) -C $@
	$(MAKE) -C $@ install

$(libsamplerate):
	wget -nc https://github.com/libsndfile/libsamplerate/releases/download/$(libsamplerate_version)/$@.tar.xz
	tar xf $@.tar.xz
	cd $@ && ./configure --prefix="$(LOCAL)"
	$(MAKE) -C $@
	$(MAKE) -C $@ install

$(libcurl):
	wget -nc https://github.com/curl/curl/releases/download/$(subst .,_,$@)/$@.tar.gz
	tar xf $@.tar.gz
	cd $@ && ./configure --prefix="$(LOCAL)" \
		--disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher --disable-manual \
		--without-zlib --without-ssl --without-ca-bundle --without-ca-path --without-ca-fallback --without-libpsl --without-libssh2 --without-librtmp --without-winidn --without-libidn2 --without-nghttp2
	$(MAKE) -C $@
	$(MAKE) -C $@ install

clean:
	git clean -fdx