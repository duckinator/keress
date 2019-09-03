GODOT ?= bin/godot-headless
EXPORT_FLAG ?= --export

# TODO: When https://github.com/cirruslabs/cirrus-ci-docs/issues/305 is
#       resolved, switch to CIRRUS_TASK_NUMBER.

# TODO: Include BUILD_ID and BUILD_HASH in the actual builds, somehow.

ifeq ($(GITHUB_CHECK_SUITE_ID),)
BUILD_ID ?= "non-release build"
else
BUILD_ID ?= ${GITHUB_CHECK_SUITE_ID}
endif

BUILD_HASH := $(git rev-parse --short HEAD)

all: debug

linux:
	mkdir -p build/linux
	${GODOT} src/project.godot ${EXPORT_FLAG} linux ../build/linux/keress.x86_64

mac:
	mkdir -p build/mac
	${GODOT} src/project.godot ${EXPORT_FLAG} macos ../build/mac/keress_macos.zp
	mv build/mac/keress_macos.zp build/mac/keress_macos.zip
	cd build/mac && unzip keress_macos.zip
	rm build/mac/keress_macos.zip

windows:
	mkdir -p build/windows
	${GODOT} src/project.godot ${EXPORT_FLAG} windows ../build/windows/keress.exe

debug:
	$(MAKE) BUILD_ID=${BUILD_ID} EXPORT_FLAG=--export-debug linux windows mac

release:
	$(MAKE) BUILD_ID=${BUILD_ID} EXPORT_FLAG=--export linux windows mac

ci-setup:
	test "${CIRRUS_CI}" = "true" && cp src/export_presets.cfg.cirrus-ci src/export_presets.cfg

test: all
	@echo "No tests to run. :("

clean:
	rm build/*.zip || exit 0
	rm build/*/* || exit 0

.PHONY: all _all_platforms test linux macos windows debug release clean ci-setup
