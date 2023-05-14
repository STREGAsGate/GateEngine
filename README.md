# Gate Engine
Gate Engine is a cross platform game engine for Swift that allows you to build 2D and 3D games.</br>
It includes simple APIs for loading resources, handling user inputs, and rendering content.
* **Data Model**: A specialized **Entity**/**Component**/**System** designed for convenience and simplicity.</br>
* **Math**: <a href="https://github.com/STREGAsGate/GameMath" target="_blank"> GameMath </a> 
is a custom package written specifically for Gate Engine that is designed to make doing math easy to read and write without needing to know the names of special functions and algorithms.

## Platform Support:
| Platform | CI | Dependencies¹ | Render | Sound | Keyboard | Mouse | Touch | Gamepad |
|---------:|:---|:--------------|:-------|:------|:----------|:-----|:------|:--------|
| [**Windows**](https://www.swift.org/getting-started/#on-windows)² | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Windows.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml) | None³ | ✔︎ | ⛌ | ✔︎ | ✔︎ | ⛌ | ◑ Buggy |
| [**macOS**]((https://apps.apple.com/us/app/xcode/id497799835)) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/macOS.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml) | None | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 
| [**Linux**](https://www.swift.org/getting-started/#on-linux)     | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Linux.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml) | *TBD* | ⛌ | ⛌ | ⛌ | ⛌ | ⛌ | ⛌
| [**iOS**/**tvOS**](https://apps.apple.com/us/app/xcode/id497799835)  | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/iOS-tvOS.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/iOS-tvOS.yml) | None | ✔︎ | ✔︎ | ⛌ | ⛌ | ✔︎ | ✔︎
| [**Android**](https://github.com/readdle/swift-android-toolchain)   | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Android.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Android.yml) | *TBD* | ⛌ | ⛌ | ⛌ | ⛌ | ⛌ | ⛌
| [**HTML5**](https://book.swiftwasm.org/getting-started/setup.html) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/HTML5.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml) | None | ✔︎| ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 


Complete: ✔︎ | Incomplete: ⛌ | Partial: ◑
<sub>
</br>¹All platforms require a functioning Swift toolchain. Click a platform above for setup information.
</br>²Windows support for Swift and Swift Package Manager is in development. Latest Swift toolchain recommended.
</sub>

## Getting Started
On most platforms, Gate Engine is a self contained Swift Package with no external dependencies. </br>
Add the package to your project like any other package and you're done.
```swift
.package(url: "https://github.com/STREGAsGate/GateEngine.git", branch: "main")
```
### Examples
A suite of example projects is available at <a href="https://github.com/STREGAsGate/GateEngineDemos" target="_blank">Gate Engine Demos</a>.

# History
Gate Engine started it's life in 2016 as a "for fun" project. It used a basic scene graph and only worked on Apple devices. Over the years it's been worked on and refactored repeatedly with a goal of building a powerful API that is very easy to use.

## Community & Followables
[![Discord](https://img.shields.io/discord/641809158051725322?label=Hang%20Out&logo=Discord&style=social)](https://discord.gg/5JdRJhD)
[![Twitter](https://img.shields.io/twitter/follow/stregasgate?style=social)](https://twitter.com/stregasgate)
[![YouTube](https://img.shields.io/youtube/channel/subscribers/UCBXFkK2B4w9856wBJfCGufg?label=Subscribe&style=social)](https://youtube.com/stregasgate)
[![Reddit](https://img.shields.io/reddit/subreddit-subscribers/stregasgate?style=social)](https://www.reddit.com/r/stregasgate/)

# Support Gate Engine!
If you appreciate this project, and want it to continue, then please consider putting some dollars into it.</br>
Every little bit helps! Support With:
<a href="https://github.com/sponsors/STREGAsGate" target="_blank">GitHub</a>,
<a href="https://ko-fi.com/STREGAsGate" target="_blank">Ko-fi</a>,
<a href="https://www.patreon.com/STREGAsGate" target="_blank">Pateron</a>
