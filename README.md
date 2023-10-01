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
</br>²Developed and tested using Ubuntu (Debian). Fedora compatibility is unknown.
</br>³Targeting recent versions of Safari, FireFox, Edge, and Chrome.
</sub>

## About
GateEngine is designed to give game developers access to approachable and intuitive APIs to build a game.

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
GateEngine has a simple and intuitive resource loading and caching API. Resources can be constructed instantly and are non-blocking. The reference returned is a cache handle and creating multiple instance of the same resource will return the same cache handle. This allows you to not have to worry about managing your resources; you can simply create one whenever you need.
```swift
// Load geometry
let geometry = Geometry(path: "model.obj")

// Reused the same cache as above. No load required.
let theSameGeometry = Geometry(path: "model.obj")
```
A resource state lets you know when a resource is ready to be accessed. In many places the resource state check is handled automatically, like when rendering. The renderer will simply skip resources that aren't available.
```swift
if resource.state == .ready {
    // ready to be accessed
}
```

Error handling is tucked away. A resource failing to load is usually a development error in games, not a runtime error. As such writing do-try-catch for every resource becomes tedious. GateEngine places errors in the resource state which allows you to simply code the game as if the resource was simply a value type. 

But if you would like to design a fail-able resource handling you can do so by checking for the error:
```swift
if case .failed(let error) = resource.state {
    // This error was already output as a warning
}
```

### Rendering
GatEngine supports native rendering backends like DirectX, Metal, and OpenGL. But you will not need to interact with them directly because GateEngine uses a high level rendering API designed to be flexible and customizable. Rendering is done in the order things are added allowing you to easily reason about the outcome.


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
// "Vertex Colors" vertex shader written in Swift
let vsh = VertexShader()
let mvp = vsh.modelViewProjectionMatrix
let vertexPosition = vsh.input.geometry(0).position
vsh.output.position = mvp * Vec4(vertexPosition, 1)
vsh.output["color"] = vsh.input.geometry(0).color

// "Tinted Texture" fragment shader written in Swift
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
If you appreciate this project, and want it to continue, then please consider putting some currency into it.
Every little bit helps! </br>
Support With:
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
GateEngine started its life in 2016 as a "for fun" project that used the typical strategy, for hobby game engine projects, of high performance and small footprint. It used a scene graph and only worked on Apple devices.
</br>
![Engine Creation 01](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EngineCreation01.jpg?raw=true)

I eventually created a deferred renderer, which is a technique that can reduce work for extremely complicated triple-A games. At the time I thought this was the greatest thing ever...
</br>
![Engine Creation 02](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EngineCreation02.jpg?raw=true)

Then I added lighting using my new found technique.
</br>
![Engine Creation 03](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EngineCreation03.jpg?raw=true)

And finally I added shadow and normal mapping.
</br>
![Engine Creation 04](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EngineCreation04.jpg?raw=true)

I eventually added skinning and UI. I created a 3D model of myself as a test and found some old game characters online as well.
</br>
![Engine Creation 05](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EngineCreation05.gif?raw=true)

At this point the engine was just a graphics simulation. And it's here where I started the re-writes...

I needed to actually build the "engine" part. Drawing stuff is actually a fairly small portion of what a game engine does.
I eventually learned about collision and different data techniques like Entity, Component, System.

Developing an engine is a large learning process. Every time you come up with a good way to do things, you will come up with a better way before you're done implementing the previous way. The process can be very demotivating, especially if you're on a schedule, such as trying to make money from it. But for me this was still just for fun.

Slowly, my skill at making engines caught up to the designs I was creating and GateEngine began to stabilize. But it was at this point that I realized I wasn't making any games. I was just building tech demos.

So I decided on my first 3D game. Espionage is a 3D stealth action game that I'm still working on today. It's inspired by the games I grew up with, and it's the kind of game I always wanted to make.
</br>
![Espionage Screenshot](https://github.com/STREGAsGate/GateEngine/blob/main/.github/resources/EspionageScreenshot.jpg?raw=true)
</br>
It's a very big project and it will likely take me a very long time to finish it as a solo developer.
I personally prefer large projects. 

I haven't yet been enticed to join a game jam, but perhaps that would be fun experience to try at some point. 
</br>
Maybe we'll have a GateJam someday!

Anyway, GateEngine was a massive undertaking, and was created to be enjoyed. So go make something awesome of your own!
