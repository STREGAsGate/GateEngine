// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "GateEngine",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .library(name: "GateEngine", targets: ["GateEngine"]),
        .library(name: "GameMath", targets: ["GameMath"]),
        .library(name: "GateUtilities", targets: ["GateUtilities"]),
    ],
    traits: [
        .default(enabledTraits: ["SIMD"]),
        
        .trait(
            name: "DISTRIBUTE",
            description: "Configures GateEngine for a distributable build. Disables some logging and enables optimizations that otherwise would inhibit development."
        ),
        .trait(
            name: "SIMD",
            description: "Enables SIMD acceleration when available."
        ),
        .trait(
            name: "HTML5",
            description: "Configures GateEngine for WebAssembly builds using the SwiftWASM project."
        ),
    ],
    dependencies: {
        var packageDependencies: [Package.Dependency] = []

        // Official
        packageDependencies.append(contentsOf: [
            .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.2.0")),
            .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.2.0")),
            .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "601.0.0")),
        ])
        
        #if false // Linting / Formating
        packageDependencies.append(contentsOf: [
            .package(url: "https://github.com/apple/swift-format.git", .upToNextMajor(from: "601.0.0")),
        ])
        #endif
        
        #if HTML5 // SwiftWASM
        // Replace swift-atomics with an explicit version pending:
        // https://github.com/apple/swift/issues/69264
        packageDependencies.removeAll(where: {
            if case .sourceControl(name: _, location: "https://github.com/apple/swift-atomics.git", requirement: _) = $0.kind {
                return true
            }
            return false
        })
        packageDependencies.append(
            .package(url: "https://github.com/apple/swift-atomics.git", exact: "1.1.0"),
        )
        packageDependencies.append(contentsOf: [
            .package(url: "https://github.com/swiftwasm/WebAPIKit.git", .upToNextMajor(from: "0.1.0")),
            .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", .upToNextMajor(from: "0.16.0")),
        ])
        #endif
        
        return packageDependencies
    }(),
    targets: {
        var targets: [Target] = []
        targets.append(contentsOf: [
            .target(name: "GateEngine",
                    dependencies: {
                        var dependencies: [Target.Dependency] = []
                        
                        dependencies.append(
                            "ECSMacros"
                        )
                        
                        dependencies.append(contentsOf: [
                            "GateUtilities",
                            "GameMath",
                            "Shaders",
                            "TrueType",
                            "LibSPNG",
                            "Gravity",
                            "uFBX",
                        ])
//                        dependencies.append(
//                            .target(name: "Vorbis",
//                                    condition: .when(platforms: .any(except: .wasi)))
//                        )
                        
                        #if os(macOS) || os(Linux)
                        dependencies.append(
                            .target(name: "OpenGL_GateEngine",
                                    condition: .when(platforms: .any(except: .windows, .wasi)))
                        )
                        #endif
                        
                        #if os(Windows)
                        dependencies.append(contentsOf: [
                            .target(name: "Direct3D12",
                                    condition: .when(platforms: [.windows])),
                            .target(name: "XAudio2",
                                    condition: .when(platforms: [.windows])),
                        ])
                        #endif
                        
                        #if os(Linux)
                        dependencies.append(contentsOf: [
                            .target(name: "LinuxSupport",
                                    condition: .when(platforms: [.linux, .android])),
                            //.target(name: "OpenALSoft",
                            //        condition: .when(platforms: [.linux, .android])),
                        ])
                        #endif
                        
                        dependencies.append(contentsOf: [
                            .product(name: "Atomics",
                                     package: "swift-atomics"),
                            .product(name: "Collections",
                                     package: "swift-collections")
                        ])

                        #if HTML5
                        dependencies.append(contentsOf: [
                            .product(name: "JavaScriptEventLoop",
                                     package: "JavaScriptKit",
                                     condition: .whenHTML5),
                            .product(name: "DOM",
                                     package: "WebAPIKit",
                                     condition: .whenHTML5),
                            .product(name: "FileSystem",
                                     package: "WebAPIKit",
                                     condition: .whenHTML5),
                            .product(name: "WebAudio",
                                     package: "WebAPIKit",
                                     condition: .whenHTML5),
                            .product(name: "Gamepad",
                                     package: "WebAPIKit",
                                     condition: .whenHTML5),
                            .product(name: "WebGL2",
                                     package: "WebAPIKit",
                                     condition: .whenHTML5),
                        ])
                        #endif
                        
                        return dependencies
                    }(),
                    resources: [
                        .copy("Resources/_PackageResources/GateEngine"),
                    ],
                    cSettings: [
                        .define("GL_SILENCE_DEPRECATION",
                            .when(platforms: [.macOS])),
                        .define("GLES_SILENCE_DEPRECATION",
                            .when(platforms: [.iOS, .tvOS])),
                    ],
                    swiftSettings: .default(withCustomization: { settings in
                        #if false
                            settings.append(.defaultIsolation(MainActor.self))
                        #endif
                        
                        settings.append(
                            .define("GATEENGINE_USE_OPENAL", .when(platforms: [.linux]))
                        )
                        
                        // MARK: Gate Engine options.
                        settings.append(contentsOf: [
                            /// Closes all open windows when the main window is closed
                            .define("GATEENGINE_CLOSES_ALLWINDOWS_WITH_MAINWINDOW",
                                .when(platforms: .desktop)),
                            /// Checks for reloadable resources and reloads them if they have changed
                            .define("GATEENGINE_ENABLE_HOTRELOADING",
                                .when(platforms: .desktop, configuration: .debug)),
                            /// The host platform requests the main window, so GateEngine won't create one until it's requested
                            .define("GATEENGINE_PLATFORM_CREATES_MAINWINDOW",
                                .when(platforms: [.iOS, .tvOS])),
                            /// The host platform updates and draws from an event callback, so GateEngine won't create a game loop.
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN",
                                    .when(platforms: .any)),
                            /// The host platform requires an intermediate task, so GateEngine won't load default systems.
                            .define("GATEENGINE_PLATFORM_DEFERS_LAUNCH",
                                .when(platforms: [.wasi])),
                        ])
                        // File System Options
                        settings.append(contentsOf: [
                            /// The host platform supports file system read/write
                            .define("GATEENGINE_PLATFORM_HAS_FILESYSTEM",
                                .when(platforms: .any)),
                            
                            /// The host platform supports Swift concurrency for file system calls
                            .define("GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem",
                                .when(platforms: .any)),
                            /// The host platform supports file system read/write without requiring Swift concurrency
                            .define("GATEENGINE_PLATFORM_HAS_SynchronousFileSystem",
                                .when(platforms: .any(except: .wasi))),
                            
                            /// The host platform supports Foundation.FileManager
                            .define("GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER",
                                .when(platforms: .any(except: .wasi))),
                        ])
       
                        // Options for development of WASI platform
                        settings.append(contentsOf: [
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN", .when(traits: ["HTML5"])),
                        ])
                        
                        #if false // Options for development of GateEngine. These should be disabled for tagged version releases.
                        #warning("GateEngine development options are enabled. These can cause strange build errors on some platforms.")
                        settings.append(contentsOf: [
                            /// Prints the output of generated shaders
                            .define("GATEENGINE_DEBUG_LAYOUT"),
                            /// Prints the output of generated shaders
                            //.define("GATEENGINE_LOG_SHADERS"),
                            /// Enables various additional checks and output for rendering
                            .define("GATEENGINE_DEBUG_RENDERING"),
                            /// Enables various additional checks and output for input
                            //.define("GATEENGINE_DEBUG_HID"),
                            /// Enables varius additional, additional, checks and output for input
                            //.define("GATEENGINE_DEBUG_HID_VERBOSE"),
                            /// Forces Apple platforms to use OpenGL for rendering
                            //.define("GATEENGINE_FORCE_OPNEGL_APPLE", .when(platforms: [.macOS, /*.iOS, .tvOS*/])),
                        ])
                        #endif
                    }),
                    plugins: [
                        //.plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
                    ]),
            
            .target(
                name: "Shaders",
                dependencies: [
                    "GateUtilities",
                    "GameMath",
                    .product(name: "Collections", package: "swift-collections")
                ],
                swiftSettings: .default(withCustomization: { settings in
                    settings.append(.define("GATEENGINE_DEBUG_SHADERS", .when(configuration: .debug)))
                })
            ),
            
                .target(
                    name: "GameMath", 
                    dependencies: [
                        "GateUtilities"
                    ], 
                    swiftSettings: .default(withCustomization: { settings in
                        #if false
                        // Possibly faster on old hardware, but less accurate.
                        // There is no reason to use this on modern hardware.
                        settings.append(.define("GameMathUseFastInverseSquareRoot"))
                        #endif
                        
                        // These settings are faster only with optimization.
                        settings.append(.define("GameMathUseSIMD", .when(traits: ["SIMD"])))
                        settings.append(.define("GameMathUseLoopVectorization", .when(traits: ["SIMD"])))
                    })
                ),
            
            .target(
                name: "GateUtilities",
                dependencies: [
                    .product(name: "Collections", package: "swift-collections")
                ],
                swiftSettings: .default
            ),
        ])
        
        // MARK: - Macros
        targets.append(contentsOf: [
            .macro(
                name: "ECSMacros",
                dependencies: [
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                    .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
                ],
                path: "Macros/ECSMacros"
            ),
        ])
        
        // MARK: - Dependencies
        
        targets.append(contentsOf: [
            // Vorbis
//            .target(name: "Vorbis",
//                    path: "Dependencies/Vorbis",
//                    publicHeadersPath: "include",
//                    cSettings: [
//                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows]))
//                    ]),
            
            // miniz
            .target(name: "miniz",
                    path: "Dependencies/miniz",
                    cSettings: [
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                        .unsafeFlags(["-Wno-conversion"]),
                    ]),
            
            // libspng
            .target(name: "LibSPNG",
                    dependencies: ["miniz"],
                    path: "Dependencies/LibSPNG",
                    cSettings: [
                        .define("SPNG_STATIC"),
                        .define("SPNG_USE_MINIZ"),
                        // When public, the miniz.h header crashes Clang on Windows since Swift 5.8.0
                        .headerSearchPath("src/"),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                        .unsafeFlags(["-Wno-conversion"]),
                    ]),
            
            // TrueType
            .target(name: "TrueType",
                    path: "Dependencies/TrueType",
                    cSettings: [
                        .define("STB_TRUETYPE_IMPLEMENTATION"), .define("STB_RECT_PACK_IMPLEMENTATION"),
                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                        .unsafeFlags(["-Wno-conversion"]),
                    ]),
            
            // Gravity
            .target(name: "Gravity",
                    path: "Dependencies/Gravity",
                    cSettings: [
                        .define("BUILD_GRAVITY_API"),
                        // WASI doesn't have umask
                        .define("umask(x)", to: "022", .when(platforms: [.wasi])),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ], linkerSettings: [
                        // For math functions
                        .linkedLibrary("m", .when(platforms: .any(except: .windows))),
                        // For path functions
                        .linkedLibrary("Shlwapi", .when(platforms: [.windows])),
                    ]),
            
            // uFBX
            .target(name: "uFBX",
                    path: "Dependencies/uFBX"),
        ])
        
        #if os(Windows)
        targets.append(contentsOf: [
            // Direct3D12
            .target(name: "Direct3D12",
                    path: "Dependencies/Direct3D12",
                    swiftSettings: .default(withCustomization: { settings in
                        settings.append(.define("Direct3D12ExcludeOriginalStyleAPI", .when(configuration: .release)))
                    })),
            // XAudio2
            .target(name: "XAudio2",
                    dependencies: ["XAudio2C"],
                    path: "Dependencies/XAudio/XAudio2"),
            .systemLibrary(name: "XAudio2C",
                           path: "Dependencies/XAudio/XAudio2C"),
        ])
        #endif
        
        #if os(macOS)
        targets.append(contentsOf: [
            .target(name: "OpenGL_GateEngine",
                    path: "Dependencies/OpenGL/OpenGL_GateEngine",
                    cSettings: [
                        .define("GL_SILENCE_DEPRECATION", .when(platforms: [.macOS])),
                        .define("GLES_SILENCE_DEPRECATION", .when(platforms: [.iOS, .tvOS])),
                    ])
        ])
        #endif
        
        #if os(Linux) || os(Android)
        targets.append(contentsOf: [
            // LinuxSupport
            .target(name: "LinuxSupport",
                    dependencies: [
                        .targetItem(name: "LinuxImports",
                                    condition: .when(platforms: [.linux])),
                        .targetItem(name: "LinuxExtensions",
                                    condition: .when(platforms: [.linux]))
                    ],
                    path: "Dependencies/LinuxSupport/LinuxSupport"),
            .target(name: "LinuxExtensions",
                    path: "Dependencies/LinuxSupport/LinuxExtensions"),
            .systemLibrary(name: "LinuxImports",
                           path: "Dependencies/LinuxSupport/LinuxImports"),
            
            // OpenGL
            .systemLibrary(name: "OpenGL_Linux",
                           path: "Dependencies/OpenGL/OpenGL_Linux"),
            .target(name: "OpenGL_GateEngine",
                    dependencies: ["OpenGL_Linux"],
                    path: "Dependencies/OpenGL/OpenGL_GateEngine")
        ])
        #endif
        
        #if os(Linux) || os(Android)
        targets.append(contentsOf: [
        // OpenALSoft
        .target(name: "OpenALSoft",
                path: "Dependencies/OpenAL/OpenALSoft",
                sources: openALSources,
                publicHeadersPath: "UnmodifiedSource/include",
                cSettings: openALCSettings,
                linkerSettings: openALLinkerSettings),
        ])
        #endif
        
        
        // MARK: - Tests
        
        targets.append(contentsOf: [
            .testTarget(name: "GateEngineTests",
                        dependencies: ["GateEngine"],
                        resources: [.copy("Resources")],
                        swiftSettings: .default(withCustomization: { settings in
                            settings.append(.define("DISABLE_GRAVITY_TESTS", .when(platforms: [.wasi])))
                        })),
            .testTarget(name: "GateUtilitiesTests",
                        dependencies: ["GateUtilities"]),
            .testTarget(name: "GameMathTests",
                        dependencies: ["GameMath"]),
            .testTarget(name: "GameMathNewTests",
                        dependencies: ["GameMath"]),
            .testTarget(name: "GravityTests",
                        dependencies: ["Gravity", "GateEngine"],
                        resources: [
                            .copy("Resources/disabled"),
                            .copy("Resources/fuzzy"),
                            .copy("Resources/infiniteloop"),
                            .copy("Resources/unittest"),
                        ],
                        swiftSettings: .default(withCustomization: { settings in
                            // https://github.com/STREGAsGate/GateEngine/issues/36
                            settings.append(.define("DISABLE_GRAVITY_TESTS", .when(platforms: [.wasi])))
                        })),
        ])
        #if !os(Windows)
        targets.append(contentsOf: [
            .testTarget(name: "GameMathSIMDTests",
                        dependencies: ["GameMath"],
                        swiftSettings: .default(withCustomization: { settings in
                            settings.append(.define("GameMathUseSIMD"))
                            settings.append(.define("GameMathUseLoopVectorization"))
                        })),
            .testTarget(name: "GameMathNewSIMDTests",
                        dependencies: ["GameMath"],
                        swiftSettings: .default(withCustomization: { settings in
                            settings.append(.define("GameMathUseSIMD"))
                            settings.append(.define("GameMathUseLoopVectorization"))
                        })),
        ])
        #endif
        
        return targets
    }(),
    swiftLanguageModes: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

#if os(Linux) || os(Android)
var openALLinkerSettings: [LinkerSetting] {
    var array: [LinkerSetting] = []
    
    array.append(contentsOf: [
        .linkedFramework("AudioToolbox", .when(platforms: .anyApple)),
        .linkedFramework("CoreFoundation", .when(platforms: .anyApple)),
        .linkedFramework("CoreAudio", .when(platforms: .anyApple)),
    ])
    // array.append(contentsOf: [
    //     .linkedLibrary("winmm", .when(platforms: [.windows])),
    //     .linkedLibrary("kernel32", .when(platforms: [.windows])),
    //     .linkedLibrary("user32", .when(platforms: [.windows])),
    //     .linkedLibrary("gdi32", .when(platforms: [.windows])),
    //     .linkedLibrary("winspool", .when(platforms: [.windows])),
    //     .linkedLibrary("shell32", .when(platforms: [.windows])),
    //     .linkedLibrary("ole32", .when(platforms: [.windows])),
    //     .linkedLibrary("oleaut32", .when(platforms: [.windows])),
    //     .linkedLibrary("uuid", .when(platforms: [.windows])),
    //     .linkedLibrary("comdlg32", .when(platforms: [.windows])),
    //     .linkedLibrary("advapi32", .when(platforms: [.windows])),
    // ])

    return array
}

var openALCSettings: [CSetting] {
    var array: [CSetting] = []
    
    array.append(.headerSearchPath("ConfiguredSource/macOS/", .when(platforms: [.macOS])))
    array.append(.headerSearchPath("ConfiguredSource/Windows/", .when(platforms: [.windows])))
    array.append(.headerSearchPath("ConfiguredSource/Linux/", .when(platforms: [.linux])))
    array.append(.headerSearchPath("ConfiguredSource/iOS/", .when(platforms: [.iOS, .tvOS, .watchOS, .macCatalyst])))
    
    array.append(.headerSearchPath("UnmodifiedSource/"))
    array.append(.headerSearchPath("UnmodifiedSource/common/"))
    array.append(.headerSearchPath("UnmodifiedSource/core/mixer"))
    
    array.append(.headerSearchPath("UnmodifiedSource/alc/backends/", .when(platforms: [.windows])))
    array.append(.headerSearchPath("UnmodifiedSource/alc/effects/", .when(platforms: [.windows])))
    array.append(.headerSearchPath("UnmodifiedSource/core/", .when(platforms: [.windows])))
    array.append(.headerSearchPath("UnmodifiedSource/core/effects/", .when(platforms: [.windows])))
    array.append(.headerSearchPath("UnmodifiedSource/core/filters/", .when(platforms: [.windows])))
    
    array.append(.define("RESTRICT", to: "__restrict"))
    array.append(.define("AL_BUILD_LIBRARY"))
    array.append(.define("AL_ALEXT_PROTOTYPES"))
    
    array.append(.define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows]))) // Silence warnings
    array.append(.define("NOMINMAX", .when(platforms: [.windows])))
    array.append(.define("AL_NO_UID_DEFS", .when(platforms: [.windows])))
    
    array.append(.define("EXPORT_DECL", to: "__declspec(dllexport)", .when(platforms: [.windows])))
    array.append(.define("ALC_API", to: "__declspec(dllexport)", .when(platforms: [.windows])))
    array.append(.define("AL_API", to: "__declspec(dllexport)", .when(platforms: [.windows])))
    array.append(.define("_WIN32", .when(platforms: [.windows])))
        
    return array
}

var openALSources: [String] {
    var array: [String] = []
    let common = [
        "UnmodifiedSource/common/alcomplex.cpp",
        "UnmodifiedSource/common/alfstream.cpp",
        "UnmodifiedSource/common/almalloc.cpp",
        "UnmodifiedSource/common/alstring.cpp",
        "UnmodifiedSource/common/dynload.cpp",
        "UnmodifiedSource/common/polyphase_resampler.cpp",
        "UnmodifiedSource/common/ringbuffer.cpp",
        "UnmodifiedSource/common/strutils.cpp",
        "UnmodifiedSource/common/threads.cpp",
    ]
    array.append(contentsOf: common)
    
    let shared = [
        "UnmodifiedSource/al/auxeffectslot.cpp",
        "UnmodifiedSource/al/buffer.cpp",
        "UnmodifiedSource/al/effect.cpp",
        "UnmodifiedSource/al/effects/effects.cpp",
        "UnmodifiedSource/al/error.cpp",
        "UnmodifiedSource/al/event.cpp",
        "UnmodifiedSource/al/extension.cpp",
        "UnmodifiedSource/al/filter.cpp",
        "UnmodifiedSource/al/listener.cpp",
        "UnmodifiedSource/al/source.cpp",
        "UnmodifiedSource/al/state.cpp",
        "UnmodifiedSource/alc/alc.cpp",
        "UnmodifiedSource/alc/alconfig.cpp",
        "UnmodifiedSource/alc/alu.cpp",
        "UnmodifiedSource/alc/backends/base.cpp",
        "UnmodifiedSource/alc/backends/loopback.cpp",
        "UnmodifiedSource/alc/backends/wave.cpp",
        "UnmodifiedSource/alc/panning.cpp",
        "UnmodifiedSource/core/ambdec.cpp",
        "UnmodifiedSource/core/ambidefs.cpp",
        "UnmodifiedSource/core/bformatdec.cpp",
        "UnmodifiedSource/core/bs2b.cpp",
        "UnmodifiedSource/core/bsinc_tables.cpp",
        "UnmodifiedSource/core/buffer_storage.cpp",
        "UnmodifiedSource/core/converter.cpp",
        "UnmodifiedSource/core/cpu_caps.cpp",
        "UnmodifiedSource/core/devformat.cpp",
        "UnmodifiedSource/core/effectslot.cpp",
        "UnmodifiedSource/core/except.cpp",
        "UnmodifiedSource/core/filters/biquad.cpp",
        "UnmodifiedSource/core/filters/nfc.cpp",
        "UnmodifiedSource/core/filters/splitter.cpp",
        "UnmodifiedSource/core/fmt_traits.cpp",
        "UnmodifiedSource/core/fpu_ctrl.cpp",
        "UnmodifiedSource/core/helpers.cpp",
        "UnmodifiedSource/core/hrtf.cpp",
        "UnmodifiedSource/core/logging.cpp",
        "UnmodifiedSource/core/mastering.cpp",
        "UnmodifiedSource/core/mixer.cpp",
        "UnmodifiedSource/core/mixer/mixer_c.cpp",
        "UnmodifiedSource/core/uhjfilter.cpp",
        "UnmodifiedSource/core/uiddefs.cpp",
        "UnmodifiedSource/core/voice.cpp",
        "ConfiguredSource/core/mixer/mixer_neon.cpp",
        "ConfiguredSource/core/mixer/mixer_sse.cpp",
        "ConfiguredSource/core/mixer/mixer_sse2.cpp",
        "ConfiguredSource/core/mixer/mixer_sse3.cpp",
        "ConfiguredSource/core/mixer/mixer_sse41.cpp",
        "UnmodifiedSource/al/effects/autowah.cpp",
        "UnmodifiedSource/al/effects/chorus.cpp",
        "UnmodifiedSource/al/effects/compressor.cpp",
        "UnmodifiedSource/al/effects/convolution.cpp",
        "UnmodifiedSource/al/effects/dedicated.cpp",
        "UnmodifiedSource/al/effects/distortion.cpp",
        "UnmodifiedSource/al/effects/echo.cpp",
        "UnmodifiedSource/al/effects/equalizer.cpp",
        "UnmodifiedSource/al/effects/fshifter.cpp",
        "UnmodifiedSource/al/effects/modulator.cpp",
        "UnmodifiedSource/al/effects/null.cpp",
        "UnmodifiedSource/al/effects/pshifter.cpp",
        "UnmodifiedSource/al/effects/reverb.cpp",
        "UnmodifiedSource/al/effects/vmorpher.cpp",
        "UnmodifiedSource/alc/context.cpp",
        "UnmodifiedSource/alc/device.cpp",
        "UnmodifiedSource/alc/effects/autowah.cpp",
        "UnmodifiedSource/alc/effects/chorus.cpp",
        "UnmodifiedSource/alc/effects/compressor.cpp",
        "UnmodifiedSource/alc/effects/convolution.cpp",
        "UnmodifiedSource/alc/effects/dedicated.cpp",
        "UnmodifiedSource/alc/effects/distortion.cpp",
        "UnmodifiedSource/alc/effects/echo.cpp",
        "UnmodifiedSource/alc/effects/equalizer.cpp",
        "UnmodifiedSource/alc/effects/fshifter.cpp",
        "UnmodifiedSource/alc/effects/modulator.cpp",
        "UnmodifiedSource/alc/effects/null.cpp",
        "UnmodifiedSource/alc/effects/pshifter.cpp",
        "UnmodifiedSource/alc/effects/reverb.cpp",
        "UnmodifiedSource/alc/effects/vmorpher.cpp",
        "UnmodifiedSource/core/context.cpp",
        "UnmodifiedSource/core/device.cpp",
        "UnmodifiedSource/alc/backends/null.cpp",
    ]
    array.append(contentsOf: shared)
    
    #if os(Windows)
    let windows = [
        // "UnmodifiedSource/al/eax/api.cpp",
        // "UnmodifiedSource/al/eax/call.cpp",
        // "UnmodifiedSource/al/eax/exception.cpp",
        // "UnmodifiedSource/al/eax/fx_slot_index.cpp",
        // "UnmodifiedSource/al/eax/fx_slots.cpp",
        // "UnmodifiedSource/al/eax/globals.cpp",
        // "UnmodifiedSource/al/eax/utils.cpp",
        // not in WinSDK for Swift yet "UnmodifiedSource/alc/backends/dsound.cpp",
        // not in WinSDK for Swift yet "UnmodifiedSource/alc/backends/wasapi.cpp",
        "UnmodifiedSource/alc/backends/winmm.cpp",
    ]
    array.append(contentsOf: windows)
    #endif
    
    #if os(macOS)
    let macOS = [
        "UnmodifiedSource/alc/backends/coreaudio.cpp",
    ]
    array.append(contentsOf: macOS)
    #endif

    #if os(Linux)
    let linux = [
        "UnmodifiedSource/alc/backends/oss.cpp",
    ]
    array.append(contentsOf: linux)
    #endif
    return array
}
#endif


// Package.swift Helpers
extension Array where Element == Platform {
    static func any(except excluding: Platform...) -> Self {
        var array = self.any
        for platform in excluding {
            array.removeAll(where: {$0 == platform})
        }
        return array
    }
    
    static var desktop: Self {[.windows, .linux, .macOS, .macCatalyst, .openbsd]}
    static var mobile: Self {[.iOS, .android]}
    static var anyApple: Self {
        return [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .macCatalyst]
    }
    
    static var any: Self {
        return [
            .macOS, .iOS, .tvOS, .watchOS, .visionOS, .macCatalyst,
            .linux, .android,
            .openbsd,
            .windows,
            .wasi,
            .driverKit,
        ]
    }
}

extension Array where Element == SwiftSetting {
    static var `default`: Self? {
        var settings: Self = []
        if let optionalFlags = Self.otherFlags {
            settings.append(contentsOf: optionalFlags)
        }
        if let upcommingFeatureFlags = Self.upcommingFeatureFlags {
            settings.append(contentsOf: upcommingFeatureFlags)
        }
        if let exprimentalFeatureFlags = Self.exprimentalFeatureFlags {
            settings.append(contentsOf: exprimentalFeatureFlags)
        }
        
        settings.append(.define("DISTRIBUTE", .when(traits: ["DISTRIBUTE"])))
        
        return settings.isEmpty ? nil : settings
    }
    
    static func `default`(withCustomization block: (_ settings: inout Self)->()) -> Self? {
        var settings: Self = .default ?? []
        block(&settings)
        return settings.isEmpty ? nil : settings
    }
    
    static var upcommingFeatureFlags: Self? {
        var settings: Self = []
        
#if compiler(>=6.2)
    #if !hasFeature(InferIsolatedConformances)
        enableFeature("InferIsolatedConformances")
    #endif
    #if !hasFeature(NonisolatedNonsendingByDefault)
        enableFeature("NonisolatedNonsendingByDefault")
    #endif
    #if !hasFeature(NonescapableTypes)
        enableFeature("NonescapableTypes")
    #endif
#endif
#if compiler(>=6.1)
    #if !hasFeature(MemberImportVisibility)
        enableFeature("MemberImportVisibility")
    #endif
#endif
#if compiler(>=6.0)
    #if !hasFeature(GlobalActorIsolatedTypesUsability)
        enableFeature("GlobalActorIsolatedTypesUsability")
    #endif
    #if !hasFeature(DynamicActorIsolation)
        enableFeature("DynamicActorIsolation")
    #endif
    #if !hasFeature(InferSendableFromCaptures)
        enableFeature("InferSendableFromCaptures")
    #endif
    #if !hasFeature(RegionBasedIsolation)
        enableFeature("RegionBasedIsolation")
    #endif
    #if !hasFeature(InternalImportsByDefault)
        enableFeature("InternalImportsByDefault")
    #endif
#endif
#if compiler(>=5.10)
    #if hasFeature(StrictConcurrency)
        enableFeature("StrictConcurrency=complete") // complete mode shows Swift v6 errors as warnings when in Swift v5
    #endif
    #if !hasFeature(GlobalConcurrency)
        enableFeature("GlobalConcurrency")
    #endif
    #if !hasFeature(IsolatedDefaultValues)
        enableFeature("IsolatedDefaultValues")
    #endif
    #if !hasFeature(DeprecateApplicationMain)
        enableFeature("DeprecateApplicationMain")
    #endif
#endif
#if compiler(>=5.9)
    #if !hasFeature(DisableOutwardActorInference)
        enableFeature("DisableOutwardActorInference")
    #endif
    #if !hasFeature(ImportObjcForwardDeclarations)
        enableFeature("ImportObjcForwardDeclarations")
    #endif
#endif
#if compiler(>=5.8)
    #if !hasFeature(ConciseMagicFile)
        enableFeature("ConciseMagicFile")
    #endif
#endif
#if compiler(>=5.7)
    #if !hasFeature(BareSlashRegexLiterals)
        enableFeature("BareSlashRegexLiterals")
    #endif
    #if !hasFeature(ImplicitOpenExistentials)
        enableFeature("ImplicitOpenExistentials")
    #endif
#endif
#if compiler(>=5.6)
    #if !hasFeature(StrictConcurrency)
        enableFeature("StrictConcurrency")
    #endif
    #if !hasFeature(ExistentialAny)
        enableFeature("ExistentialAny")
    #endif
#endif
#if compiler(>=5.3)
    #if !hasFeature(ForwardTrailingClosures)
        enableFeature("ForwardTrailingClosures")
    #endif
#endif
        
        func enableFeature(_ feature: String, _ condition: PackageDescription.BuildSettingCondition? = nil) {
            settings.append(.enableUpcomingFeature(feature, condition))
        }
        return settings.isEmpty ? nil : settings
    }
    
    static var exprimentalFeatureFlags: Self? {
        var settings: Self = []
        
#if compiler(>=6.2)
    #if !hasFeature(IsolatedDeinit)
        enableFeature("IsolatedDeinit")
    #endif
#endif
        
        func enableFeature(_ feature: String, _ condition: PackageDescription.BuildSettingCondition? = nil) {
            settings.append(.enableExperimentalFeature(feature, condition))
        }
        return settings.isEmpty ? nil : settings
    }
    
    static var otherFlags: Self? {
        var settings: Self = []

// #if compiler(>=6.2)
//         addFlag("-strict-memory-safety", .when(configuration: .debug))
// #endif
                
        func enableFeature(_ feature: String, _ condition: PackageDescription.BuildSettingCondition? = nil) {
            settings.append(.enableExperimentalFeature(feature, condition))
        }
        func addFlags(_ flags: String...) {
            settings.append(.unsafeFlags(flags, nil))
        }
        func addFlags(_ flags: [String], _ condition: PackageDescription.BuildSettingCondition? = nil) {
            settings.append(.unsafeFlags(flags, condition))
        }
        func addFlag(_ flags: String, _ condition: PackageDescription.BuildSettingCondition? = nil) {
            settings.append(.unsafeFlags([flags], condition))
        }
        return settings.isEmpty ? nil : settings
    }
}

extension PackageDescription.TargetDependencyCondition {
    static var whenHTML5: Self? {.when(platforms: [.wasi], traits: ["HTML5"])}
}
