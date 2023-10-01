# GateEngine
A cross platform game engine for Swift that allows you to build 2D and 3D games.</br>
GateEngine includes intuitive APIs for loading resources, handling user inputs, and rendering content.

## Platform Support:
| Platform | CI | Graphics | Audio | Keyboard | Mouse | Touch | Gamepad |
|---------:|:---|:---------|:------|:---------|:------|:------|:--------|
| [**Windows**](https://www.swift.org/getting-started/#on-windows)¹ | [![5.8](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Windows.yml?label=Swift%205.8)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Windows.yml) | ✔︎ | ◑ | ✔︎ | ✔︎ | ⛌ | ✔︎ |
| [**macOS**](https://apps.apple.com/us/app/xcode/id497799835) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/macOS.yml?label=Swift%205.9)](https://github.com/STREGAsGate/GateEngine/actions/workflows/macOS.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 
| [**Linux**](https://www.swift.org/getting-started/#on-linux)² | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Linux.yml?label=Swift%205.9)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Linux.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ⛌ | ✔︎
| [**iOS**/**tvOS**](https://apps.apple.com/us/app/xcode/id497799835) | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/iOS-tvOS.yml?label=Swift%205.9)](https://github.com/STREGAsGate/GateEngine/actions/workflows/iOS-tvOS.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎`iPad` | ✔︎`iOS` | ✔︎
| **Android** | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/Android.yml?label=)](https://github.com/STREGAsGate/GateEngine/actions/workflows/Android.yml) | ⛌ | ⛌ | ⛌ | ⛌ | ⛌ | ⛌
| [**HTML5**](https://book.swiftwasm.org/getting-started/setup.html)³ | [![](https://img.shields.io/github/actions/workflow/status/STREGAsGate/GateEngine/HTML5.yml?label=Swift%205.8)](https://github.com/STREGAsGate/GateEngine/actions/workflows/HTML5.yml) | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | ✔︎ | 

Complete: ✔︎ | Incomplete: ⛌ | Partial: ◑
<sub>
</br>All platforms require a functioning Swift toolchain. Click a platform above for setup information.
</br>¹Windows support for Swift and Swift Package Manager is in development. Latest Swift toolchain recommended.
</br>²Developed and tested using Ubuntu (debian). Fedora compatibility is unknown.
</br>³Targeting recent versions of Safari, FireFox, Edge, and Chrome.
</sub>

## About
GateEngine is designed to give game developers access to approachable and intitive APIs to build a game.

### Math
GateEngine has a custom math library completely coded in Swift. GameMath allows developers to write math functions using a spoken language style API. GameMath uses context aware types like `Position3`, `Direction3`, and `Size3` instead of a catch all `vector` type. This adds an addition layer of understanding to APIs because arguments have inherent context.
```swift
let position: Position3 = Position3(0, 1, 0) * Size3(1, 1, 1)
...
let moved: Position3 = position.moved(units, toward: direction)
...
let reflected: Direction3 = direction.reflected(off: surfaceNormal)
...
let halfway = source.interpolated(to: destination, .linear(0.5))
```

### Resources
GateEngine has a simple and intuitive resource loading and caching API. Resources can be constructed instantly and are non-blocking. The reference returned is a cache handle and creating multiplke instance of the same resource will return the same cache handle. This allows you to not have to worry about managing your resources; you can simply create one whenever you need.
```swift
// Load geometry
let gemomtry = Geometry(path: "model.obj")

// Reused the same cache as above. No load required.
let theSameGeometry = Geometry(path: "model.obj")
```
A resource state lets you know when a reosurce is ready to be accessed. In many places the resource state check is handled automatically, like when rendering. The renderer will simply skip resources that arent available.
```swift
if resource.state == .ready {
    // ready to be accessed
}
```

Error handling is tucked away. A resource failing to load is usually a development error in games, not a runtime error. As such writing do-try-catch for every resource becomes tedious. GateEngine places errors in the resource state which allows you to simply code the game as if the resource was simply a value type. 

But if you would like to design a failable resource handling you can do so by checking for the error:
```swift
if case .failed(let error) = resoruce.state {
    // This error was already output as a warning
}
```

### Rendering
GatEngine supports native rendering backends like DirectX, Metal, and OpenGL. But you will not need to interact with them directly becuase GateEngine uses a high level rendering API designed to be flexible and customizable. Rendering is done in the order things are added allowing you to easily reason about the outcome.


```swift
// Create a 2D draw container
var canvas = Canvas()

// Draw a sprite at a specific location 
canvas.insert(sprite, at: position)

// Draw the canvas inside the window
window.insert(canvas)
```
<sub>Advanced users can also leverage the lower level DrawCommand API for even more customizability.</sub>

### Shaders
GateEngine uses a custom designed Swift based shader language. This shader language allows you to write your shaders in Swift, directly inside your project and they will automatically work on every platform. There are no files or cross-compile tools to mess with.

For high level rendering, shaders are handled automatically and there's no need to make any.
```swift
// "Vertex Colors" vertex shader writen in Swift
let vsh = VertexShader()
let mvp = vsh.modelViewProjectionMatrix
let vertexPosition = vsh.input.geometry(0).position
vsh.output.position = mvp * Vec4(vertexPosition, 1)
vsh.output["color"] = vsh.input.geometry(0).color

// "Tinted Texture" fragment shader writen in Swift
let fsh = FragmentShader()
let sample = fsh.channel(0).texture.sample(
    at: fsh.input["texCoord0"],
    filter: .nearest
)
fsh.output.color = sample * fsh.channel(0).color
```
<sub>*Shader are currently under development are missing some functionality.*</sub>

## Getting Started
Add the package to your project like any other package and you're done:
```swift
.package(
    url: "https://github.com/STREGAsGate/GateEngine.git",
    .upToNextMajor(from: "0.1.0")
)
```

### Windows Specific Setup
Swift 5.9.0 Only: A linker error for dinput.lib can be solved by following the workaround [here](https://github.com/apple/swift/issues/68887).

### Linux Specific Setup
For Linux you must install dev packages for OpenGL and OpenAL.
On Ubuntu the following terminal commands will install the needed packages:
```sh
sudo apt-get update --fix-missing
sudo apt-get install freeglut3-dev
sudo apt-get install libopenal-dev
```

# Examples
A suite of example projects is available at [GateEngine Demos](https://github.com/STREGAsGate/GateEngineDemos)</a>.

# Support GateEngine!
GateEngine relies on community funding.
If you appreciate this project, and want it to continue, then please consider putting some currency into it.</br>
Every little bit helps! Support With:
[GitHub](https://github.com/sponsors/STREGAsGate),
[Ko-fi](https://ko-fi.com/STREGAsGate),
or
[Patreon](https://www.patreon.com/STREGAsGate).

## Community & Followables
A GateEngine development blog is published on Discord [here](https://discord.gg/PfqFwQPV96).</br>
Discord is also a great place to ask questions or show off your creations.

[![Discord](https://img.shields.io/discord/641809158051725322?label=Hang%20Out&logo=Discord&style=social)](https://discord.gg/5JdRJhD)
[![Twitter](https://img.shields.io/twitter/follow/stregasgate?style=social)](https://twitter.com/stregasgate)
[![YouTube](https://img.shields.io/youtube/channel/subscribers/UCBXFkK2B4w9856wBJfCGufg?label=Subscribe&style=social)](https://youtube.com/stregasgate)
[![Reddit](https://img.shields.io/reddit/subreddit-subscribers/stregasgate?style=social)](https://www.reddit.com/r/stregasgate/)

# History
GateEngine started it's life in 2016 as a "for fun" project that used the typical strategy, for hobby game engine projects, of high performance and small footprint. It used a basic scene graph and only worked on Apple devices.

After years of frustration over the amount of time spent building games using "optimal" code, I decided to try making an engine that focused on making the process of building a game more intuitive. This lead to a custom math library that uses spoken language APIs instead like:
```swift
let newPosition = position.moved(units, toward: direction)
```
A high level renderer which allows loading content with a single initializer:
```swift
let gpuReadyMesh = Geometry(path: "model.obj")
let gpuReadyTexture = Texture(path: "image.png")
```
A rendering API that uses containers that allow layering style that's easy to reason about:
```swift
var canvas = Canvas()

canvas.insert(sprite, at: position)

window.insert(canvas)
```
And a custom Swift shader API:
```swift

```
After several years of slowly adding and replacing more and more APIs with approachable and fun ones, GateEngine was born. This repository is a fresh project and I'm slowly moving over features from my private engine, while fixing things that are less polished along the way.

This project was a massive undertaking, and was created to be enjoyed. So go make something awesome!
