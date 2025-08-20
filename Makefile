PLATFORM ?= PLATFORM_DESKTOP
BUILD_MODE ?= RELEASE
TOOLCHAIN ?= MINGW

RAYLIB_DIR = C:/raylib
INCLUDE_DIR = -I ./ -I $(RAYLIB_DIR)/raylib/src -I $(RAYLIB_DIR)/raygui/src
LIBRARY_DIR = -L $(RAYLIB_DIR)/raylib/src
DEFINES = -D _DEFAULT_SOURCE -D RAYLIB_BUILD_MODE=$(BUILD_MODE) -D $(PLATFORM)

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(TOOLCHAIN),MSVC)
        CC = cl
        EXT = .exe
        RAYLIB_MSVC_LIBDIR ?= $(RAYLIB_DIR)/build/raylib/Release
        DEFINES_MSVC = /D RAYLIB_BUILD_MODE=$(BUILD_MODE) /D $(PLATFORM)
        INCLUDE_DIR_MSVC = /I . /I $(RAYLIB_DIR)/raylib/src /I $(RAYLIB_DIR)/raygui/src
        ifeq ($(BUILD_MODE),RELEASE)
            CFLAGS ?= /EHsc /O2 /std:c++17 $(DEFINES_MSVC) $(INCLUDE_DIR_MSVC)
        else
            CFLAGS ?= /EHsc /Zi /std:c++17 $(DEFINES_MSVC) $(INCLUDE_DIR_MSVC)
        endif
        LIBS_MSVC = /link /LIBPATH:$(RAYLIB_MSVC_LIBDIR) raylib.lib opengl32.lib gdi32.lib winmm.lib
    else
        CC = g++
        EXT = .exe
        ifeq ($(BUILD_MODE),RELEASE)
            CFLAGS ?= $(DEFINES) -ffast-math -march=native -D NDEBUG -O3 $(RAYLIB_DIR)/raylib/src/raylib.rc.data $(INCLUDE_DIR) $(LIBRARY_DIR) 
		else
            CFLAGS ?= $(DEFINES) -g $(RAYLIB_DIR)/raylib/src/raylib.rc.data $(INCLUDE_DIR) $(LIBRARY_DIR) 
        endif
        LIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
    endif
endif

ifeq ($(PLATFORM),PLATFORM_WEB)
    CC = emcc
    EXT = .html
    CFLAGS ?= $(DEFINES) $(RAYLIB_DIR)/raylib/src/libraylib.bc -ffast-math -D NDEBUG -O3 -s USE_GLFW=3 -s FORCE_FILESYSTEM=1 -s MAX_WEBGL_VERSION=2 -s ALLOW_MEMORY_GROWTH=1 --preload-file $(dir $<)resources@resources --shell-file ./shell.html $(INCLUDE_DIR) $(LIBRARY_DIR)
endif

SOURCE = $(wildcard *.cpp)
HEADER = $(wildcard *.h)

.PHONY: all

all: controller

controller: $(SOURCE) $(HEADER)
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(TOOLCHAIN),MSVC)
	$(CC) /Fe:$@$(EXT) $(SOURCE) $(CFLAGS) $(LIBS_MSVC)
    else
	$(CC) -o $@$(EXT) $(SOURCE) $(CFLAGS) $(LIBS)
    endif
else
	$(CC) -o $@$(EXT) $(SOURCE) $(CFLAGS) $(LIBS)
endif

clean:
	rm controller$(EXT)