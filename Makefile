GODOT := bin/godot-headless

GODOT_DOWNLOAD_URL := https://downloads.tuxfamily.org/godotengine/3.1.1/Godot_v3.1.1-stable_linux_headless.64.zip

DATE := $(shell date +"%Y-%m-%d")
REV := $(shell git rev-parse --short HEAD)

all: debug

linux: ${GODOT}
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} linux ../build/${BUILD_TYPE}/keress.x86_64

macos: ${GODOT}
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} macos ../build/${BUILD_TYPE}/keress_macos.zp
	mv build/${BUILD_TYPE}/keress_macos.z{,i}p

windows: ${GODOT}
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

bin/godot-headless:
	rm -f bin/godot-headless
	mkdir ./tmp
	wget ${GODOT_DOWNLOAD_URL} -O ./tmp/godot-headless.zip
	unzip ./tmp/godot-headless.zip
	mv Godot_*_linux_headless.64 bin/godot-headless
	rm -r ./tmp/

test:
	@echo TODO

clean:
	rm build/*.zip || exit 0
	rm build/*/* || exit 0

.PHONY: all _all_platforms linux macos windows debug release clean
