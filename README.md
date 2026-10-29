# Simple Timer

A simple native macOS timer built with SwiftUI.

- Keyboard entry for minutes and seconds
- Editable timer name, saved between launches
- Always on Top toggle
- Resizable window
- Start, pause, reset, and a completion sound

## Download

Open this repository’s **Releases** section and download **SimpleTimer-macOS-AppleSilicon.zip** from the latest release. Unzip it and drag **SimpleTimer.app** into Applications.

Requires **Apple Silicon (M1 or later) and macOS 14 or later**.

This development build is ad-hoc signed and **not notarized by Apple**. macOS may prevent it from opening. Only if you trust this app, try opening it, then select **System Settings → Privacy & Security → Open Anyway** if available.

## Use

Enter minutes (0–999) and seconds (0–59), then click **Start**. Click **Pause** to pause and **Reset** to restore the configured duration. The pin toggles Always on Top.

Space starts or pauses the timer when you are not editing text. Command-R resets it. Drag the window edges to resize it.

The timer includes elapsed time while the Mac is asleep and updates after waking. A completion sound and Dock attention request indicate completion; there is no completion message. The title is saved between launches. Timer duration and progress are not saved when you quit.

## Build

Install Xcode Command Line Tools, then run:

```sh
bash build.sh
open SimpleTimer.app
```

The build script targets Apple Silicon and macOS 14 or later. No third-party dependencies are required.

## Release

Push a version tag such as `v0.4.0`. The GitHub Actions workflow builds the app, packages a ZIP, calculates a SHA-256 checksum, and attaches both files to a GitHub Release. A manual workflow run builds a downloadable Actions artifact without publishing a release.

Developer ID signing and Apple notarization are not configured.
