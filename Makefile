GODOT := bin/godot-headless

GODOT_VERSION := 3.1.1

GODOT_DOWNLOAD_URL := https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip
GODOT_EXPORT_TEMPLATE_URL := https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz
GODOT_TEMPLATE_DIR := ${HOME}/.local/share/godot/templates/


DATE := $(shell date +"%Y-%m-%d")
REV := $(shell git rev-parse --short HEAD)

all: debug

linux: ${GODOT}
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} linux ../build/${BUILD_TYPE}/keress.x86_64

macos: ${GODOT}
	mkdir -p build/${BUILD_TYPE}
	${GODOT} src/project.godot ${EXPORT_FLAG} macos ../build/${BUILD_TYPE}/keress_macos.zp
	mv build/${BUILD_TYPE}/keress_macos.zp build/${BUILD_TYPE}/keress_macos.zip

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
	curl -sS ${GODOT_DOWNLOAD_URL} | funzip > bin/godot-headless
	chmod +x bin/godot-headless

ci-download-export-templates:
	mkdir -p ${GODOT_TEMPLATE_DIR}
	cd ${GODOT_TEMPLATE_DIR} && curl -sS ${GODOT_EXPORT_TEMPLATE_URL} -o godot-templates.zip
	cd ${GODOT_TEMPLATE_DIR} && unzip godot-templates.zip
	cd ${GODOT_TEMPLATE_DIR} && mv ./templates ${GODOT_VERSION}.stable

ci-setup: bin/godot-headless ci-download-export-templates
	test "${CIRRUS_CI}" = "true" && cp src/export_presets.cfg.cirrus-ci src/export_presets.cfg

ci-nightly:
	test "${BRANCH}" = "nightly" && $(MAKE) nightly-publish

test:
	@echo TODO

clean:
	rm build/*.zip || exit 0
	rm build/*/* || exit 0

.PHONY: all _all_platforms test linux macos windows debug release clean ci-download-export-templates ci-setup ci-nightly
