#!/usr/bin/env bash

if [ "$(git branch --show-current)" = "main" ]; then
    git rev-list --count main
else
    echo "non-release build"
fi
