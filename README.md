# Gate Engine

[![Windows](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml/badge.svg)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml)
[![macOS](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml/badge.svg)](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml)
[![Linux](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml/badge.svg)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml)
[![HTML5](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml/badge.svg)](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml)

## What is Gate Engine?
Gate Engine is a cross platform game engine for Swift that allows you to build 2D and 3D games.</br>
It includes simple APIs for loading resources, handling user inputs, and rendering content.
* **Data Model**: A specialized **Entity**/**Component**/**System** designed for convenience and simplicity.</br>
* **Math**: <a href="https://github.com/STREGAsGate/GameMath" target="_blank"> GameMath </a> 
is a custom package written specifically for Gate Engine that is designed to make doing math easy to read and write without needing to know the names of special functions and algorithms.

## Platform Support:
| | Dependencies¹ | Render | Sound | Mouse/Key | Gamepad | Touch | CI
|:----------|:----------|:----------|:----------|:----------|:----------|:----------|:----------|
| **Windows²**   |<span style="color:green"> None³ |<span style="color:green">✔︎</span> |<span style="color:red">⛌ |<span style="color:green">✔︎ |<span style="color:orange">◑</span> Buggy |<span style="color:red">⛌ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Windows.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml) |
| **macOS**     |<span style="color:green">None |<span style="color:green">✔︎</span> |<span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/macOS.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml) |
| **Linux**     | *TBD* |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Linux.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml) |
| **iOS**/**tvOS**  |<span style="color:green">None |<span style="color:green">✔︎</span> | <span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎
| **Android**   | *TBD* |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌ |<span style="color:red">⛌
| **HTML5**     |<span style="color:green">None |<span style="color:green">✔︎</span> | <span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎ |<span style="color:green">✔︎ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/HTML5.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml) |


Complete: <span style="color:green">✔︎</span> | Incomplete: <span style="color:red">⛌</span> | Partial: <span style="color:orange">◑</span>
<sub>
</br>¹All platforms require a functioning Swift toolchain. Xcode on macOS, see <a href="https://swift.org/getting-started" target="_blank">Getting Started</a> for other platforms.
</br>²Windows support for Swift and Swift Package Manager is in development and **will** be buggy.
</br>³The latest Swift toolchain is always highly recommended.
</sub>

## Getting Started
On most platforms, Gate Engine is a self contained Swift Package with no external dependencies. </br>
Add the package to your project like any other package and you're done.
```swift
.package(url: "https://github.com/STREGAsGate/GateEngine.git", branch: "main")
```
A suite of example projects is available at <a href="https://github.com/STREGAsGate/GateEngineDemos" target="_blank">Gate Engine Demos</a>.

### Notice ⚠️
This package is very much in **Beta**. The API surface will be changing, possibly substantially.
</br>
Once a versioned release is made the project will use Swift's availability API for deprecations and easy migration.</br>
However, in the mean time please be aware that pulling updates may break your project and require some fixes.
</br>
<sub>If you have an issue pulling changes you may need to do `swift package reset` or reset package caches from Xcode.</sub>

# History
Gate Engine started it's life in 2016 as a "for fun" project. It used a basic scene graph and only worked on Apple devices. Over the years it's been worked on and refactored repeatedly with a goal of building a powerful API that is very easy to use.

# Support Gate Engine!
If you appreciate this project, and want it to continue, then please consider putting some dollars into it.</br>
Every little bit helps! Support With:
<a href="https://github.com/sponsors/STREGAsGate" target="_blank">GitHub</a>,
<a href="https://ko-fi.com/STREGAsGate" target="_blank">Ko-fi</a>,
<a href="https://www.patreon.com/STREGAsGate" target="_blank">Pateron</a>

## Community & Followables
[![Discord](https://img.shields.io/discord/641809158051725322?label=Hang%20Out&logo=Discord&style=social)](https://discord.gg/5JdRJhD)
[![Twitter](https://img.shields.io/twitter/follow/stregasgate?style=social)](https://twitter.com/stregasgate)
[![YouTube](https://img.shields.io/youtube/channel/subscribers/UCBXFkK2B4w9856wBJfCGufg?label=Subscribe&style=social)](https://youtube.com/stregasgate)
[![Reddit](https://img.shields.io/reddit/subreddit-subscribers/stregasgate?style=social)](https://www.reddit.com/r/stregasgate/)
