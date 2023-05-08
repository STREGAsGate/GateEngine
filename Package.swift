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
    targets: {
        var targets: [Target] = []
        targets.append(contentsOf: [
            .target(name: "GateEngine",
                    dependencies: {
                        var dependencies: [Target.Dependency] = []
                        dependencies.append(contentsOf: ["GameMath", "Shaders", "TrueType", "LibSPNG"])
                        dependencies.append(.target(name: "Vorbis", condition: .when(platforms: [.macOS, .windows, .linux, .iOS, .tvOS, .android])))
                        
                        #if os(Windows)
                        dependencies.append(.target(name: "Direct3D12", condition: .when(platforms: [.windows])))
                        #endif
                        
                        #if os(Linux)
                        dependencies.append(.target(name: "LinuxSupport", condition: .when(platforms: [.linux])))
                        #endif
                        
                        dependencies.append(.product(name: "Atomics", package: "swift-atomics", condition: .when(platforms: [.macOS, .linux, .iOS, .tvOS, .android, .wasi])))
                        dependencies.append(.product(name: "Collections", package: "swift-collections"))

                        #if os(macOS) || os(Linux)
                        dependencies.append(contentsOf: [
                            .product(name: "JavaScriptEventLoop", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
                            .product(name: "DOM", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                            .product(name: "WebAudio", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                            .product(name: "Gamepad", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                            .product(name: "WebGL2", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                        ])
                        #endif
                        
                        return dependencies
                    }(),
                    resources: [
                        .copy("_Resources/GateEngine"),
                        .copy("System/HID/GamePad/GamePadInterpreter/Interpreters/HID/Mapping/SDL2/SDL2 Game Controller DB.txt"),
                    ],
                    swiftSettings: [
                        // MARK: Gate Engine options for parent targets to impliment.
                        .define("GATEENGINE_ENABLE_HOTRELOADING", .when(platforms: [.macOS, .windows, .linux])),
                        
                        // MARK: Options for development of GateEngine. These should be commented out for a tagged version releases.
                        .define("GATEENGINE_ENABLE_WASI_IDE_SUPPORT", .when(platforms: [.macOS, .linux], configuration: .debug)),
                        .define("GATEENGINE_LOG_SHADERS", .when(configuration: .debug)),
                        .define("GATEENGINE_DEBUG_RENDERING", .when(configuration: .debug)),
                    ],
                    linkerSettings: [
                        // .linkedLibrary("GameMath", .when(platforms: [.windows])),
                    ]),
            
            .target(name: "Shaders", dependencies: ["GameMath"]),
        ])
        
        // MARK: - GateEngineDependencies
        
        // LinuxSupport
        targets.append(contentsOf: [
            .target(name: "LinuxSupport",
                    dependencies: [.targetItem(name: "LinuxImports", condition: .when(platforms: [.linux])),
                                   .targetItem(name: "LinuxExtensions", condition: .when(platforms: [.linux]))],
                    path: "Sources/GateEngineDependencies/LinuxSupport/LinuxSupport"),
            .target(name: "LinuxExtensions",
                    path: "Sources/GateEngineDependencies/LinuxSupport/LinuxExtensions"),
            .systemLibrary(name: "LinuxImports",
                           path: "Sources/GateEngineDependencies/LinuxSupport/LinuxImports"),
        ])
        
        targets.append(contentsOf: [
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
                        .define("SPNG_STATIC"),
                        .define("SPNG_USE_MINIZ"),
                        // miniz.h crashes the Swift compiler on Windows, when public, as of Swift 5.8.0
                        .headerSearchPath("src/"),
                        // Silence warnings
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), 
                    ],
                    linkerSettings: [
                        // SR-14728
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
            
            // Direct3D12
            .target(name: "Direct3D12",
                    path: "Sources/GateEngineDependencies/Direct3D12",
                    swiftSettings: [
                        .define("Direct3D12ExcludeOriginalStyleAPI", .when(configuration: .release)),
                    ],
                    linkerSettings: [
                        .linkedLibrary("User32"),
                        .linkedLibrary("Ole32"),
                        .linkedLibrary("PortableDeviceGuids"),
                        .linkedLibrary("DXGI"),
                        .linkedLibrary("D3D12"),
                        .linkedLibrary("D3DCompiler"),
                    ])
        ])
        
  
        
        // MARK: - Tests
        targets.append(contentsOf: [
            .testTarget(name: "GateEngineTests", dependencies: ["GateEngine"]),
        ])
        
        return targets
    }()
)

