# Gate Engine
A cross platform game engine for Swift that allows you to build 2D and 3D games.</br>
Gate Engine includes intuitive APIs for loading resources, handling user inputs, and rendering content.

## Platform Support:
| Platform | CI | Graphics | Audio | Keyboard | Mouse | Touch | Gamepad |
|---------:|:---|:---------|:------|:---------|:------|:------|:--------|
| [**Windows**](https://www.swift.org/getting-started/#on-windows) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Windows.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml) | ✔︎ | ◑ | ✔︎ | ✔︎ | ⛌ | ✔︎ |
| [**macOS**](https://apps.apple.com/us/app/xcode/id497799835) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/macOS.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 
| [**Linux**](https://www.swift.org/getting-started/#on-linux)² | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Linux.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ⛌ | ✔︎
| [**iOS**/**tvOS**](https://apps.apple.com/us/app/xcode/id497799835) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/iOS-tvOS.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/iOS-tvOS.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎`iPad` | ✔︎ | ✔︎
| **Android** | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Android.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Android.yml) | ⛌ | ⛌ | ⛌ | ⛌ | ⛌ | ⛌
| [**HTML5**](https://book.swiftwasm.org/getting-started/setup.html)³ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/HTML5.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 

Complete: ✔︎ | Incomplete: ⛌ | Partial: ◑
<sub>
</br>All platforms require a functioning Swift toolchain. Click a platform above for setup information.
</br>¹Windows support for Swift and Swift Package Manager is in development. Latest Swift toolchain recommended.
</br>²Developed and tested using Ubuntu (debian). Fedora based Linux support is unknown and not a priority.
</br>³Targeting recent versions of Safari, FireFox, Edge, and Chrome. Other support is not a priority.
</sub>

## Getting Started
On most platforms, Gate Engine is a self contained Swift Package with no external dependencies. </br>
Add the package to your project like any other package and you're done.
```swift
.package(url: "https://github.com/STREGAsGate/GateEngine.git", .upToNextMajor(from: "0.0.8"))
```

### Linux Extra Setup
For Linux you must install dev packages for OpenGL and OpenAL.
On Ubuntu the following terminal commands will install the needed packages:
```sh
sudo apt-get update --fix-missing
sudo apt-get install freeglut3-dev
sudo apt-get install libopenal-dev
```

## Examples
A suite of example projects is available at [Gate Engine Demos](https://github.com/STREGAsGate/GateEngineDemos)</a>.

# Support Gate Engine!
If you appreciate this project, and want it to continue, then please consider putting some currency into it.</br>
Every little bit helps! Support With:
[GitHub](https://github.com/sponsors/STREGAsGate),
[Ko-fi](https://ko-fi.com/STREGAsGate),
or
[Patreon](https://www.patreon.com/STREGAsGate).

## Community & Followables
[![Discord](https://img.shields.io/discord/641809158051725322?label=Hang%20Out&logo=Discord&style=social)](https://discord.gg/5JdRJhD)
[![Twitter](https://img.shields.io/twitter/follow/stregasgate?style=social)](https://twitter.com/stregasgate)
[![YouTube](https://img.shields.io/youtube/channel/subscribers/UCBXFkK2B4w9856wBJfCGufg?label=Subscribe&style=social)](https://youtube.com/stregasgate)
[![Reddit](https://img.shields.io/reddit/subreddit-subscribers/stregasgate?style=social)](https://www.reddit.com/r/stregasgate/)

# History
Gate Engine started it's life in 2016 as a "for fun" project that used the typical strategy, for hobby game engine projects, of high performance and small footprint. It used a basic scene graph and only worked on Apple devices.

After years of frustration over the amount of time spent building games using "optimal" code, I decided to try making an engine that focused on making the process of building a game more fun. This lead to a custom math library that uses spoken language APIs instead like `position.move(units, toward: direction)`. Then I added a high level renderer which allows loading content with a single initializer `Geometry(path: "model.obj")`, and a drawing API that uses primitives in a layer style to easily reason about the outcome.

After several years of slowly adding and replacing more and more APIs with approachable and fun ones, GateEngine was born. This repository is a fresh project and I'm slowly moving over features from my private engine, while fixing things that are less polished along the way.

This project was a massive undertaking, and was created to be enjoyed. So go make something awesome!
