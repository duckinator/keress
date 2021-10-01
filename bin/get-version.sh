#!/usr/bin/env bash

if [ "${CIRRUS_BRANCH}" = "main" ] || [ "$(git branch --show-current)" = "main" ]; then
    git rev-list --count main
else
    echo "non-release build"
fi
