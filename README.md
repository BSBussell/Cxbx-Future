# Cxbx-Future - Xbox Emulator Specialized for JSRF

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](COPYING)


[Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded) is an emulator for running Microsoft Xbox games on Windows and through Wine.
**Cxbx-Future** is my fork, focused on making Jet Set Radio Future nicer to play.

> We don't provide game files. You'll need to dump your own legally owned copy!

## Future Patches!

Cxbx-Future keeps the September 2022 [Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded) source base and builds on it with small, focused fixes for JSRF.
The first priority is getting rid of the "white flash" bug, reported on AMD systems among others.
There are other usability changes I'd like to make, but I'm taking this one patch at a time.

### Changes and their writeups

- **[White-flash fix](docs/Future/white-flash-fix.md):** Prevents the intermittent white flashes caused by shared rendering state. The writeup explains the flashbang problem, why I think the fix improves the JSRF experience, and the technical changes and testing behind it.
- More, maybe...

Every feature added to this fork should have a writeup in **[docs/Future/](docs/Future/README.md)**: what changed, why I think it improves the UX, how it works, and what we've tested. That also means being clear about limitations and any competitive-integrity considerations.

## System Requirements

### Minimum

  * OS: Windows 7+ x64, or x86-64 Linux with Wine. 32-bit is not supported.
    * MacOS with Wine has been tested to work using CrossOver
    * BSD-based systems are untested.
    * Wine and CrossOver compatibility can vary between versions and setups.
  * GPU: Direct3D 9.0c with Pixel Shader Model 2.x, and Vertex Shader Model 3.0.

## Prerequisites

### Windows

  * [32-bit (x86) Visual C++ 2022 Redistributable](https://aka.ms/vs/17/release/vc_redist.x86.exe)
  * [Npcap *(used for network emulation)*](https://nmap.org/npcap/#download)
    * Make sure to enable winpcap compatibility mode.
  * WinUSB compliant driver
    * *Optional, only needed for USB pass-through of original Xbox and Steel Battalion controllers.*

### Wine

This fork has been tested locally through CrossOver on macOS. Generally part of the goal of this project is to make it easier to run JSRF on Linux and MacOS.
  * Winetricks
    * `vcrun2019`
      * Requires the latest winetricks script.
    * `d3dcompiler_47`
      * This may be subject to change.
  * Winpcap is built-in, no installation is required.

## Builds

There aren't any public builds yet; this is still in development. If you're fiending, send me a DM on [Bluesky](https://bsky.app/profile/bbussell.com) or something :3

## Compatibility

Cxbx-Future may run other Xbox games, but JSRF is the focus of development and testing. Please don't assume the changes have been validated for other games.

## Bug Reports

For problems with this fork, use the [Cxbx-Future issue tracker](https://github.com/BSBussell/Cxbx-Future/issues). Include the build or commit, the game version, your Windows or Wine/CrossOver setup, and steps to reproduce the problem. Error text, logs, and screenshots help too!

Please keep questions and reports about Cxbx-Future here or [get in touch with me](https://bsky.app/profile/bbussell.com). I'm maintaining this fork independently, and I don't want the original project's community to have to troubleshoot my messes :D

## Contributing

Small, focused contributions are welcome! Include a [feature writeup](docs/Future/README.md) explaining the change, its purpose, and how you checked it.

For larger changes, get in touch first so we can agree on the scope before you sink a bunch of time into it.

### Main Prerequisites

1. [Git for Windows](https://git-scm.com)
2. [CMake](https://cmake.org)
    * Some IDEs already have CMake support, this is optional.

### Fetching the code

1. Run the following command in the command line:
<br>`git clone --recurse-submodules --branch CXBX-Future https://github.com/BSBussell/Cxbx-Future.git`
    * Please note the `--recurse-submodules` parameter. This is required to fetch submodules.
    * `--branch CXBX-Future` selects the branch containing this fork's changes.
      * If Cxbx-Future was checked out without submodules, they can be updated/fetched with the following command:

        `git submodule update --init --recursive`

### Compiling

#### Windows

Don't open `CMakeLists.txt` from Visual Studio, as it won't generate files in the `build` directory.

##### Prerequisites

1. [Visual Studio](https://visualstudio.microsoft.com/downloads/) 2022
    * C++ and C# desktop development
    * MSVC v143 x64/x86 tools **v14.33-17.3** and Windows SDK **10.0.19041.0** (individual components).
    * Windows Universal CRT SDK
    * C++ CMake tools for Windows
      * *Optional if CMake is installed*
    * [Microsoft Child Process Debugging Power Tool](https://marketplace.visualstudio.com/items?itemName=vsdbgplat.MicrosoftChildProcessDebuggingPowerTool)

##### Build if you don't wanna open Visual Studio

With the prerequisites installed and Git and CMake on PATH, run this from the repository root:

```bat
build-release.cmd
```

The script selects the pinned x86 compiler and builds the Release launcher and emulator without opening Visual Studio. The output is in `build-2022-v143/bin/Release`; keep that folder's binaries and shaders together when running.

##### Generate Visual Studio files

1. If you don't have CMake installed, open `___ Native Tools Command Prompt for VS 20##`.
2. `cd` to the Cxbx-Future directory.
3. Run these commands.
    1. `mkdir build & cd build`
    2. `cmake .. -G "Visual Studio 17 2022" -A Win32 -T "v143,version=14.33.31629" -DCMAKE_SYSTEM_VERSION=10.0.19041.0`
        * VS2022 17.0 or later is required.
4. Open `Cxbx-Reloaded.sln` from the `build` directory.
5. Select the Release configuration, then click Build.
    * Debug builds are **significantly slower, and only for developers**.

#### Linux / macOS

The build instructions above produce Windows binaries. I've tested running them on macOS through CrossOver; I haven't tested this fork on Linux yet.

## Support

Feel free to support [Luke Usher](https://github.com/LukeUsher), initiator of [Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded), on [Patreon](https://www.patreon.com/LukeUsher).

Without his work this project would not be possible.

## Special Thanks

* All contributors to the original [Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded), Cxbx and [Dxbx](https://github.com/PatrickvL/Dxbx) projects. This fork wouldn't exist without their work.
* [XQEMU](https://github.com/xqemu/xqemu) - The upstream NV2A LLE and NVNet implementations draw on the XQEMU developers' work.
* [XboxDev](https://github.com/xboxdev) - Providing Xbox hardware research & useful tooling.
* [XbSymbolDatabase](https://github.com/Cxbx-Reloaded/XbSymbolDatabase) - Providing support to detect symbols across XDK builds from reverse engineered retail titles.
* [Xbox Kernel Test Suite](https://github.com/Cxbx-Reloaded/xbox_kernel_test_suite) - Making accurate tests on hardware to compare against cxbxr's kernel implementation.
