// swift-tools-version:5.7
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
                dependencies: {
                    var array: [Target.Dependency] = []
                    array.append(contentsOf: ["GameMath", "Shaders", "TrueType", "LibSPNG"])
                    array.append(.target(name: "Vorbis", condition: .when(platforms: [.macOS, .windows, .linux, .iOS, .tvOS, .android])))
                    
                    #if os(Linux)
                    array.append(.target(name: "LinuxSupport", condition: .when(platforms: [.linux])))
                    #endif

                    array.append(.product(name: "Atomics", package: "swift-atomics"))
                    array.append(.product(name: "Collections", package: "swift-collections"))
                    
                    #if os(macOS) || os(Linux)
                    array.append(.product(name: "JavaScriptEventLoop", package: "JavaScriptKit", condition: .when(platforms: [.wasi])))
                    array.append(.product(name: "DOM", package: "WebAPIKit", condition: .when(platforms: [.wasi])))
                    array.append(.product(name: "WebAudio", package: "WebAPIKit", condition: .when(platforms: [.wasi])))
                    array.append(.product(name: "Gamepad", package: "WebAPIKit", condition: .when(platforms: [.wasi])))
                    array.append(.product(name: "WebGL2", package: "WebAPIKit", condition: .when(platforms: [.wasi])))
                    #endif
                    
                    return array
                }(),
                resources: [
                    .copy("_Resources/GateEngine"),
                    .copy("System/HID/GamePad/GamePadInterpreter/Interpreters/HID/Mapping/SDL2/SDL2 Game Controller DB.txt"),
                ],
                swiftSettings: [
                    .define("SUPPORTS_HOTRELOADING", .when(platforms: [.macOS, .windows, .linux], configuration: .debug)),
                    //.define("GATEENGINE_WASI_IDE_SUPPORT"),
                ],
                linkerSettings: [
                    .linkedLibrary("GameMath", .when(platforms: [.windows])),
                ]),
        
        .target(name: "Shaders", dependencies: ["GameMath"]),
        
        // MARK: - GateEngineDependencies
        
        // LinuxSupport
        .target(name: "LinuxSupport",
                dependencies: ["LinuxImports", "LinuxExtensions"],
                path: "Sources/GateEngineDependencies/LinuxSupport/LinuxSupport"),
        .target(name: "LinuxExtensions",
                path: "Sources/GateEngineDependencies/LinuxSupport/LinuxExtensions"),
        .systemLibrary(name: "LinuxImports",
                       path: "Sources/GateEngineDependencies/LinuxSupport/LinuxImports"),
        
        // Vorbis
        .target(name: "Vorbis",
                path: "Sources/GateEngineDependencies/Vorbis",
                publicHeadersPath: "include",
                cSettings: [
                    .unsafeFlags(["-Wno-everything"]),
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows]))
                ],
                linkerSettings: [
                    // SR-14728
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ]),
        
        // libspng
        .target(name: "LibSPNG",
                path: "Sources/GateEngineDependencies/LibSPNG",
                cSettings: [
                    .unsafeFlags(["-Wno-everything"]),
                    .define("SPNG_USE_MINIZ"),
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                    .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                ],
                linkerSettings: [
                    // SR-14728\
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ]),
        
        // TrueType
        .target(name: "TrueType",
                path: "Sources/GateEngineDependencies/TrueType",
                cSettings: [
                    .unsafeFlags(["-Wno-everything"]),
                    .define("STB_TRUETYPE_IMPLEMENTATION"), .define("STB_RECT_PACK_IMPLEMENTATION"),
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                    .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                ],
                linkerSettings: [
                    // SR-14728
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ]),
        
        // MARK: - Tests
        .testTarget(name: "GateEngineTests", dependencies: ["GateEngine"]),
    ]
)

