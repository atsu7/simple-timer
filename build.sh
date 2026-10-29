#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p SimpleTimer.app/Contents/MacOS
cp Resources/Info.plist SimpleTimer.app/Contents/Info.plist
mkdir -p .build-cache
xcrun swiftc -module-cache-path .build-cache -parse-as-library -O -target arm64-apple-macosx14.0 Sources/SimpleTimer.swift -o SimpleTimer.app/Contents/MacOS/SimpleTimer
codesign --force --sign - SimpleTimer.app
echo 'Built SimpleTimer.app'
