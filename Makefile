all: debug

linux:
	mkdir -p build/${BUILD_TYPE}
	godot src/project.godot ${EXPORT_FLAG} linux ../build/${BUILD_TYPE}/keress.x86_64

macos:
	mkdir -p build/${BUILD_TYPE}
	godot src/project.godot ${EXPORT_FLAG} macos ../build/${BUILD_TYPE}/keress_macos.zp
	mv build/${BUILD_TYPE}/keress_macos.z{,i}p

windows:
	mkdir -p build/${BUILD_TYPE}
	godot src/project.godot ${EXPORT_FLAG} windows ../build/${BUILD_TYPE}/keress.exe

_all_platforms:
	$(MAKE) linux EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}
	$(MAKE) macos EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}
	$(MAKE) windows EXPORT_FLAG=${EXPORT_FLAG} BUILD_TYPE=${BUILD_TYPE}

debug:
	$(MAKE) _all_platforms EXPORT_FLAG=--export-debug BUILD_TYPE=debug
	zip -r keress-debug.zip build/debug

release:
	$(MAKE) _all_platforms EXPORT_FLAG=--export BUILD_TYPE=release
	zip -r keress-release.zip build/release

test:
	@echo TODO

clean:
	rm build/*/*

.PHONY: all _all_platforms linux macos windows debug release clean
