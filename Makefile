GODOT := bin/godot-headless

DATE := $(shell date +"%Y-%m-%d")
REV := $(shell git rev-parse --short HEAD)

all: debug

linux:
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} linux ../build/${BUILD_TYPE}/keress.x86_64

macos:
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} macos ../build/${BUILD_TYPE}/keress_macos.zp
	mv build/${BUILD_TYPE}/keress_macos.zp build/${BUILD_TYPE}/keress_macos.zip

windows:
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} windows ../build/${BUILD_TYPE}/keress.exe

_all_platforms:
	$(MAKE) linux EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}
	$(MAKE) macos EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}
	$(MAKE) windows EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}

debug:
	$(MAKE) _all_platforms EXPORT_FLAG=--export-debug BUILD_TYPE=debug
	cd build/ && zip -r keress-debug-${DATE}-${REV}.zip debug

release:
	$(MAKE) _all_platforms EXPORT_FLAG=--export BUILD_TYPE=release
	cd build/ && zip -r keress-release-${DATE}-${REV}.zip release

ci-setup:
	test "${CIRRUS_CI}" = "true" && cp src/export_presets.cfg.cirrus-ci src/export_presets.cfg

ci-nightly-publish: all
	./bin/nightly/release.sh

test: all
	@echo "No tests to run. :("

clean:
	rm build/*.zip || exit 0
	rm build/*/* || exit 0

.PHONY: all _all_platforms test linux macos windows debug release clean ci-setup ci-nightly-publish
