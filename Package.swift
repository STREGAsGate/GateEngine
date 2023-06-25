// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GateEngine",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(name: "GateEngine", targets: ["GateEngine"]),
    ],
    dependencies: {
        var packageDependencies: [Package.Dependency] = []

        packageDependencies.append(contentsOf: [
            // Official
            .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.1.0")),
            .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        ])

        // SwiftWASM
        #if os(macOS) || os(Linux)
        packageDependencies.append(contentsOf: [
//            .package(url: "https://github.com/swiftwasm/WebAPIKit.git", branch: "main"),
//            .package(url: "https://github.com/strega/JavaScriptKit.git", .upToNextMajor(from: "0.16.0")),
            .package(path: "~/Documents/GitHub/WebAPIKit"),
            .package(path: "~/Documents/GitHub/JavaScriptKit")
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
                        dependencies.append(contentsOf: ["GameMath", "Shaders", "TrueType", "LibSPNG"])
                        dependencies.append(.target(name: "Vorbis", condition: .when(platforms: [.macOS, .windows, .linux, .iOS, .tvOS, .android])))
                        
                        #if os(macOS) || os(Linux)
                        dependencies.append(.target(name: "OpenGL_GateEngine", condition: .when(platforms: [.macOS, .iOS, .tvOS, .linux, .android])))
                        #endif
                        
                        #if os(Windows)
                        dependencies.append(.target(name: "Direct3D12", condition: .when(platforms: [.windows])))
                        // XAudio is C++ and won't be available on all Swift versions so we'll use OpenAL as a fallback
                        dependencies.append(.target(name: "OpenALSoft", condition: .when(platforms: [.windows])))
                        #if swift(>=5.10)
                        #warning("Reminder: Check XAudio2 C++ build support.")
                        #endif
                        #endif
                        
                        #if os(Linux)
                        dependencies.append(.target(name: "LinuxSupport", condition: .when(platforms: [.linux, .android])))
                        // dependencies.append(.target(name: "OpenALSoft", condition: .when(platforms: [.linux, .android])))
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
                    ],
                    cSettings: [
                        .define("GL_SILENCE_DEPRECATION", .when(platforms: [.macOS, .iOS, .tvOS])),
                        .define("GLES_SILENCE_DEPRECATION", .when(platforms: [.iOS, .tvOS])),
                    ],
                    swiftSettings: {
                        var settings: [SwiftSetting] = []
                        
                        settings.append(contentsOf: [
                            // MARK: Gate Engine options.
                            /// Closes all open windows when the main window is closed
                            .define("GATEENGINE_CLOSES_ALLWINDOWS_WITH_MAINWINDOW", .when(platforms: [.macOS, .windows, .linux])),
                            /// Checks for reloadable resources and reloads them if they have changed
                            .define("GATEENGINE_ENABLE_HOTRELOADING", .when(platforms: [.macOS, .windows, .linux], configuration: .debug)),
                            /// THe host platfrom requests the main window, so GateEngine won't create one until it's requested
                            .define("GATEENGINE_PLATFORM_CREATES_MAINWINDOW", .when(platforms: [.iOS, .tvOS])),
                            /// The host platform can't be usaed to compile HTML5 products
                            .define("GATEENGINE_WASI_UNSUPPORTED_HOST", .when(platforms: [.windows])),
                            /// The host platform updates and draws from an event callback, so GateEngine won't create a game loop.
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN", .when(platforms: [.wasi])),
                            /// The host pltfrom requires an intermediate task, so GateEngine won't load default systems.
                            .define("GATEENGINE_PLATFORM_DEFERS_LAUNCH", .when(platforms: [.wasi])),
                        ])
                        
                        #if false // Options for development of GateEngine. These should be commented out for tagged version releases.
                        #warning("GateEngine development options are enabled. These can cause strange build errors on some platforms.")
                        
                        // Options for developemnt of WASI platform
                        #if true
                        settings.append(contentsOf: [
                            /// Allows HTML5 platform to be compiled from a compatible host, such as macOS. This allows the IDE to show compile errors without targeting WASI.
                            .define("GATEENGINE_ENABLE_WASI_IDE_SUPPORT", .when(platforms: [.macOS, .linux], configuration: .debug)),
                            /// see comment in "Gate Engine options".
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN", .when(platforms: [.macOS, .linux, .wasi], configuration: .debug)),
                        ])
                        #endif
                        
                        settings.append(contentsOf: [
                            /// Printes the output of generated shaders
                            .define("GATEENGINE_LOG_SHADERS"),
                            /// Enables varius additional checks and output for rendering
                            .define("GATEENGINE_DEBUG_RENDERING"),
                            /// Enables varius additional checks and output for input
                            .define("GATEENGINE_DEBUG_HID"),
                            /// Forces Apple platforms to use OpenGL for rendering
                            .define("GATEENGINE_FORCE_OPNEGL_APPLE", .when(platforms: [.macOS, .iOS, .tvOS])),
                        ])
                        #endif
                        return settings
                    }(),
                    linkerSettings: [

                    ]),
            
            .target(name: "Shaders", dependencies: ["GameMath"]),
            
            .target(name: "GameMath", swiftSettings: {
                var array: [SwiftSetting] = []
                
                #if false
                // A little bit faster on old hardware, but less accurate.
                // Theres no reason to use this on modern hardware.
                array.append(.define("GameMathUseFastInverseSquareRoot"))
                #endif
                
                // These settings are faster only with optimization.
                #if true
                array.append(.define("GameMathUseSIMD", .when(configuration: .release)))
                array.append(.define("GameMathUseLoopVectorization", .when(configuration: .release)))
                #endif
                
                return array.isEmpty ? nil : array
            }()),
        ])
        
        // MARK: - GateEngineDependencies
        
        targets.append(contentsOf: [
            // Vorbis
            .target(name: "Vorbis",
                    path: "Sources/GateEngineDependencies/Vorbis",
                    publicHeadersPath: "include",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows]))
                    ]),
            
            // miniz
            .target(name: "MiniZ",
                    path: "Sources/GateEngineDependencies/MiniZ",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        // Silence warnings
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ]),
            
            // libspng
            .target(name: "LibSPNG",
                    dependencies: ["MiniZ"],
                    path: "Sources/GateEngineDependencies/LibSPNG",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("SPNG_STATIC"),
                        .define("SPNG_USE_MINIZ"),
                        // miniz.h crashes the Swift compiler on Windows, when public, as of Swift 5.8.0
                        .headerSearchPath("src/"),
                        // Silence warnings
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ]),
            
            // TrueType
            .target(name: "TrueType",
                    path: "Sources/GateEngineDependencies/TrueType",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("STB_TRUETYPE_IMPLEMENTATION"), .define("STB_RECT_PACK_IMPLEMENTATION"),
                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                    ]),
        ])
        
        #if os(Windows)
        targets.append(
            // Direct3D12
            .target(name: "Direct3D12",
                    path: "Sources/GateEngineDependencies/Direct3D12",
                    swiftSettings: [
                        .define("Direct3D12ExcludeOriginalStyleAPI", .when(configuration: .release)),
                    ])
        )
        #endif
        
        #if os(macOS)
        targets.append(contentsOf: [
            .target(name: "OpenGL_GateEngine",
                    path: "Sources/GateEngineDependencies/OpenGL/OpenGL_GateEngine",
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
                    dependencies: [.targetItem(name: "LinuxImports", condition: .when(platforms: [.linux])),
                                   .targetItem(name: "LinuxExtensions", condition: .when(platforms: [.linux]))],
                    path: "Sources/GateEngineDependencies/LinuxSupport/LinuxSupport"),
            .target(name: "LinuxExtensions",
                    path: "Sources/GateEngineDependencies/LinuxSupport/LinuxExtensions"),
            .systemLibrary(name: "LinuxImports",
                           path: "Sources/GateEngineDependencies/LinuxSupport/LinuxImports"),
            
            // OpenGL
            .systemLibrary(name: "OpenGL_Linux",
                           path: "Sources/GateEngineDependencies/OpenGL/OpenGL_Linux"),
            .target(name: "OpenGL_GateEngine",
                    dependencies: ["OpenGL_Linux"],
                    path: "Sources/GateEngineDependencies/OpenGL/OpenGL_GateEngine")
        ])
        #endif
        
        #if os(Linux) || os(Android) || os(Windows)
        targets.append(contentsOf: [
        // OpenALSoft
        .target(name: "OpenALSoft",
                path: "Sources/GateEngineDependencies/OpenAL/OpenALSoft",
                sources: openALSources,
                publicHeadersPath: "UnmodifiedSource/include",
                cxxSettings: openALCXXSettings,
                swiftSettings: {
                    var array: [SwiftSetting] = []
                    #if compiler(>=5.9)
                    array.append(.interoperabilityMode(.Cxx))
                    #else
                    array.append(.unsafeFlags(["-enable-experimental-cxx-interop", "-cxx-interoperability-mode=default"]))
                    #endif
                    return array
                }(),
                linkerSettings: openALLinkerSettings),
        ])
        #endif
        
        // MARK: - Tests
        targets.append(contentsOf: [
            .testTarget(name: "GateEngineTests", dependencies: ["GateEngine"]),
            .testTarget(name: "GameMathTests",
                        dependencies: ["GameMath"]),
        ])
        #if !os(Windows)
        targets.append(contentsOf: [
            .testTarget(name: "GameMathSIMDTests",
                        dependencies: ["GameMath"],
                        swiftSettings: [
                            .define("GameMathUseSIMD"),
                            .define("GameMathUseLoopVectorization")
                        ]),
        ])
        #endif
        
        return targets
    }(),
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

#if os(Linux) || os(Android) || os(Windows)
var openALLinkerSettings: [LinkerSetting] {
    var array: [LinkerSetting] = []
    
    array.append(contentsOf: [
        .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .tvOS, .iOS, .watchOS, .macCatalyst])),
        .linkedFramework("CoreFoundation", .when(platforms: [.macOS, .tvOS, .iOS, .watchOS, .macCatalyst])),
        .linkedFramework("CoreAudio", .when(platforms: [.macOS, .tvOS, .iOS, .watchOS, .macCatalyst])),
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

var openALCXXSettings: [CXXSetting] {
    var array: [CXXSetting] = []
    
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
    
    // Clang crashes with intrinsics on Windows
    array.append(.unsafeFlags(["-O0"], .when(platforms: [.windows], configuration: .release)))
    
    array.append(.unsafeFlags(["-Wno-everything"]))
    
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
