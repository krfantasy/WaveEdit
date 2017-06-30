VERSION = v0.3.2

FLAGS = -Wall -Wno-unused -O2 \
	-DVERSION=$(VERSION) \
	-I. -Iimgui -Inoc -Ikissfft \
	$(shell pkg-config --cflags --static sdl2) \
	$(shell pkg-config --cflags samplerate)
CFLAGS =
CXXFLAGS = -std=c++11
LDFLAGS =


SOURCES = \
	kissfft/kiss_fft.c \
	kissfft/tools/kiss_fftr.c \
	lodepng/lodepng.cpp \
	imgui/imgui.cpp \
	imgui/imgui_draw.cpp \
	imgui/imgui_demo.cpp \
	imgui/examples/sdl_opengl2_example/imgui_impl_sdl.cpp \
	$(wildcard src/*.cpp)


# OS-specific
MACHINE = $(shell gcc -dumpmachine)
ifneq (,$(findstring linux,$(MACHINE)))
	# Linux
	ARCH = lin
	FLAGS += $(shell pkg-config --cflags gtk+-2.0)
	LDFLAGS += -lGL -lpthread \
		$(shell pkg-config --libs sdl2) \
		$(shell pkg-config --libs samplerate) \
		-lgtk-x11-2.0 -lgobject-2.0
	SOURCES += src/noc_file_dialog_gtk.c
else ifneq (,$(findstring apple,$(MACHINE)))
	# Mac
	ARCH = mac
	LDFLAGS += -stdlib=libc++ -lpthread -framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo \
		$(shell pkg-config --libs sdl2) \
		$(shell pkg-config --libs samplerate)
	SOURCES += src/noc_file_dialog_osx.m
else ifneq (,$(findstring mingw,$(MACHINE)))
	# Windows
	ARCH = win
	FLAGS += -D_USE_MATH_DEFINES
	LDFLAGS += \
		$(shell pkg-config --libs samplerate) \
		$(shell pkg-config --libs sdl2) \
		-lopengl32 -mwindows
	SOURCES += src/noc_file_dialog_win.c
else
	$(error Could not determine machine type. Try hacking around in the Makefile)
endif


OBJECTS = $(SOURCES:%=%.o)


all: WaveEdit

run: all
	./WaveEdit

debug: all
	gdb -ex 'run' ./WaveEdit

WaveEdit: $(OBJECTS)
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	rm -frv $(OBJECTS) WaveEdit dist

.PHONY: dist
dist: WaveEdit
	mkdir -p dist/WaveEdit
	cp -R banks dist/WaveEdit
	cp LICENSE* dist/WaveEdit
ifeq ($(ARCH),lin)
	cp -R logo* fonts waves dist/WaveEdit
	cp WaveEdit WaveEdit.sh dist/WaveEdit
	cp /usr/lib/libSDL2-2.0.so.0 dist/WaveEdit
	cp /usr/lib/libsamplerate.so.0 dist/WaveEdit
else ifeq ($(ARCH),win)
	cp -R logo* fonts waves dist/WaveEdit
	cp WaveEdit.exe dist/WaveEdit
	cp /mingw64/bin/libgcc_s_seh-1.dll dist/WaveEdit
	cp /mingw64/bin/libsamplerate-0.dll dist/WaveEdit
	cp /mingw64/bin/libstdc++-6.dll dist/WaveEdit
	cp /mingw64/bin/libwinpthread-1.dll dist/WaveEdit
	cp /mingw64/bin/SDL2.dll dist/WaveEdit
else ifeq ($(ARCH),mac)
	mkdir -p dist/WaveEdit/WaveEdit.app/Contents/MacOS
	mkdir -p dist/WaveEdit/WaveEdit.app/Contents/Resources
	cp Info.plist dist/WaveEdit/WaveEdit.app/Contents
	cp WaveEdit dist/WaveEdit/WaveEdit.app/Contents/MacOS
	cp -R logo* fonts waves dist/WaveEdit/WaveEdit.app/Contents/Resources
	# TODO dylibs
endif
	cd dist && zip -9 -r WaveEdit_$(VERSION)_$(ARCH).zip WaveEdit


%.c.o: %.c
	$(CC) $(FLAGS) $(CFLAGS) -c -o $@ $<

%.cpp.o: %.cpp
	$(CXX) $(FLAGS) $(CXXFLAGS) -c -o $@ $<

%.m.o: %.m
	$(CC) $(FLAGS) $(CFLAGS) -c -o $@ $<