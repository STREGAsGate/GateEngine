// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GateEngine",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(name: "GateEngine", targets: ["GateEngine"]),
    ],
    dependencies: [
        // GateEngine
        .package(path: "GateEngineDependencies"),
        .package(url: "https://github.com/STREGAsGate/GameMath.git", branch: "master"),
        
        // Official
        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        
        // SwiftWASM
        .package(url: "https://github.com/swiftwasm/WebAPIKit.git", branch: "main"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", .upToNextMajor(from: "0.16.0")),
    ],
    targets: [
        .target(name: "GateEngine",
                dependencies: [
                    "GameMath",
                    .product(name: "Shaders", package: "GateEngineDependencies"),
                    .product(name: "TrueType", package: "GateEngineDependencies"),
                    .product(name: "libspng", package: "GateEngineDependencies"),
                    .product(name: "Vorbis", package: "GateEngineDependencies", condition: .when(platforms: [
                        .macOS, .windows, .linux, .iOS, .tvOS, .android
                    ])),
                    
                    .product(name: "Atomics", package: "swift-atomics"),
                    .product(name: "Collections", package: "swift-collections"),
                    
                    .product(name: "JavaScriptEventLoop", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
                    .product(name: "DOM", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                    .product(name: "WebAudio", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                    .product(name: "Gamepad", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                    .product(name: "WebGL2", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                ],
                resources: [
                    .copy("_Resources/GateEngine"),
                    .copy("System/HID/GamePad/GamePadInterpreter/Interpreters/HID/Mapping/SDL2/SDL2 Game Controller DB.txt"),
                ],
                swiftSettings: [
                    .define("SUPPORTS_HOTRELOADING", .when(platforms: [.macOS, .windows, .linux])),
                    //.define("GATEENGINE_WASI_IDE_SUPPORT"),
                ],
                linkerSettings: [
                    .linkedLibrary("GameMath", .when(platforms: [.windows])),
                ]),
        .testTarget(name: "GateEngineTests", dependencies: ["GateEngine"]),
    ]
)

