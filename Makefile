GODOT ?= bin/godot-headless

all: debug

linux:
	mkdir -p build/linux
	${GODOT} src/project.godot ${EXPORT_FLAG} linux ../build/linux/keress.x86_64

mac:
	mkdir -p build/mac
	${GODOT} src/project.godot ${EXPORT_FLAG} macos ../build/mac/keress_macos.zp
	mv build/mac/keress_macos.zp build/mac/keress_macos.zip

windows:
	mkdir -p build/windows
	${GODOT} src/project.godot ${EXPORT_FLAG} windows ../build/windows/keress.exe

debug:
	$(MAKE) EXPORT_FLAG=--export-debug linux windows mac

release:
	$(MAKE) EXPORT_FLAG=--export linux windows mac

ci-setup:
	test "${CIRRUS_CI}" = "true" && cp src/export_presets.cfg.cirrus-ci src/export_presets.cfg

ci-nightly-publish: all
	./bin/nightly/release.py

test: all
	@echo "No tests to run. :("

clean:
	rm build/*.zip || exit 0
	rm build/*/* || exit 0

.PHONY: all _all_platforms test linux macos windows debug release clean ci-setup ci-nightly-publish
