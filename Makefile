GODOT ?= tools/godot
EXPORT_FLAG ?= --export-release

GODOT_VERSION := 4.3-stable
GODOT_TEMPLATE_PATH := ${HOME}/.local/share/godot/export_templates
GODOT_TEMPLATE_DIR := 4.3.stable

GODOT_TEMPLATES := ${GODOT_TEMPLATE_PATH}/${GODOT_TEMPLATE_DIR}

# TODO: When https://github.com/cirruslabs/cirrus-ci-docs/issues/305 is
#       resolved, switch to CIRRUS_TASK_NUMBER.

# TODO: Include BUILD_ID and BUILD_HASH in the actual builds, somehow.

BUILD_HASH != git rev-parse --short HEAD
VERSION != ./bin/get-version.sh

all: debug

${GODOT_TEMPLATES}:
	mkdir -p "${GODOT_TEMPLATE_PATH}"
	curl -sSL https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz -o godot-templates.zip
	unzip godot-templates.zip
	mv ./templates ${GODOT_TEMPLATES}
	rm godot-templates.zip

godot-templates: ${GODOT_TEMPLATES}

tools/godot:
	curl -sSL https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip | funzip > tools/godot
	chmod +x tools/godot

godot: ${GODOT} godot-templates

build_info:
	printf "${VERSION}" > src/version.txt
	echo "{\"version\": \"${VERSION}\", \"build_hash\": \"${BUILD_HASH}\", \"cirrus_task_id\": \""${CIRRUS_TASK_ID}"\"}" > src/build_info.json

linux: build_info godot
	mkdir -p build/linux
	${GODOT} --headless src/project.godot ${EXPORT_FLAG} linux ../build/linux/keress.x86_64

mac: build_info godot
	mkdir -p build/mac
	${GODOT} --headless src/project.godot ${EXPORT_FLAG} macos ../build/mac/keress_macos.zip
	cd build/mac && unzip keress_macos.zip
	rm build/mac/keress_macos.zip

windows: build_info godot
	mkdir -p build/windows
	${GODOT} --headless src/project.godot ${EXPORT_FLAG} windows ../build/windows/keress.exe

release:
	$(MAKE) EXPORT_FLAG=--export-release linux windows mac

debug-linux:
	$(MAKE) EXPORT_FLAG=--export-debug linux

debug-windows:
	$(MAKE) EXPORT_FLAG=--export-debug windows

debug-mac:
	$(MAKE) EXPORT_FLAG=--export-debug mac

debug: debug-linux debug-windows debug-mac

ci-setup:
	test "${CIRRUS_CI}" = "true" && cp src/export_presets.cfg.cirrus-ci src/export_presets.cfg

tools/butler:
	curl -sSL https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default > butler.zip
	unzip -p butler.zip butler > tools/butler
	rm butler.zip
	chmod +x tools/butler
	./tools/butler -V

test: debug-linux
	@echo "No tests to run. :("

clean:
	rm -rf build/

.PHONY: all test linux macos windows debug release clean ci-setup godot godot-templates
