# Raylib Quickstart - Zig Makefile
# Wraps `zig build` for the Zig port. For legacy C/C++ builds, use `build/premake5` + `make` as before.
# See README.md for details.

ZIG ?= zig
ZIG_BUILD_ARGS ?=

.PHONY: all build debug release run clean help

all: build

build:
	$(ZIG) build $(ZIG_BUILD_ARGS)

debug:
	$(ZIG) build -Doptimize=Debug $(ZIG_BUILD_ARGS)

release:
	$(ZIG) build -Doptimize=ReleaseFast $(ZIG_BUILD_ARGS)

run:
	$(ZIG) build $(ZIG_BUILD_ARGS)
	./zig-out/bin/raylib_quickstart

clean:
	rm -rf zig-out zig-cache .zig-cache
	@echo "Cleaned Zig artifacts (zig-out, .zig-cache)"

help:
	@echo "Targets:"
	@echo "  make          - Build (windowed desktop: GLFW + OpenGL 3.3 by default)"
	@echo "  make build    - Same as above (native windowed screen)"
	@echo "  make debug    - Debug build (windowed desktop)"
	@echo "  make release  - Release build (windowed desktop)"
	@echo "  make run      - Build and run windowed desktop version from project root (so resources/ resolves)"
	@echo "  make clean    - Remove build artifacts"
	@echo ""
	@echo "Zig options (passed via ZIG_BUILD_ARGS or directly):"
	@echo "  zig build                                        # windowed desktop (default: -Dplatform=glfw -Dopengl_version=gl_3_3, requires X11 dev headers)"
	@echo "  zig build -Dplatform=memory -Dopengl_version=gl_soft # headless software rendering (no X11 needed, no window)"
	@echo ""
	@echo "Legacy C/C++ (premake):"
	@echo "  cd build && ./premake5 gmake && cd .. && make -f Makefile.premake"
