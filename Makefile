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
	$(ZIG) build run $(ZIG_BUILD_ARGS)

clean:
	rm -rf zig-out zig-cache .zig-cache
	@echo "Cleaned Zig artifacts (zig-out, .zig-cache)"

help:
	@echo "Targets:"
	@echo "  make          - Build (debug, headless memory backend by default)"
	@echo "  make build    - Same as above"
	@echo "  make debug    - Debug build"
	@echo "  make release  - Release build"
	@echo "  make run      - Build and run"
	@echo "  make clean    - Remove build artifacts"
	@echo ""
	@echo "Zig options (passed via ZIG_BUILD_ARGS or directly):"
	@echo "  zig build -Dplatform=glfw -Dopengl_version=gl_3_3   # windowed desktop (requires X11 dev headers)"
	@echo "  zig build -Dplatform=memory -Dopengl_version=gl_soft # headless (default, no X11 needed)"
	@echo ""
	@echo "Legacy C/C++ (premake):"
	@echo "  cd build && ./premake5 gmake && cd .. && make -f Makefile.premake"
