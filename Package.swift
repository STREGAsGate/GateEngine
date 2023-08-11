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
            //.package(url: "https://github.com/apple/swift-format", branch: "main"),
        ])

        // SwiftWASM
        #if os(macOS) || os(Linux)
        packageDependencies.append(contentsOf: [
            .package(url: "https://github.com/swiftwasm/WebAPIKit.git", branch: "main"),
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
                        dependencies.append(contentsOf: ["GameMath", "Shaders", "TrueType", "LibSPNG", "Gravity"])
                        dependencies.append(.target(name: "Vorbis", condition: .when(platforms: .any(except: .wasi))))
                        
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
                        
                        dependencies.append(.product(name: "Atomics", package: "swift-atomics", condition: .when(platforms: .any(except: .windows))))
                        dependencies.append(.product(name: "Collections", package: "swift-collections"))

                        #if os(macOS) || os(Linux)
                        dependencies.append(contentsOf: [
                            .product(name: "JavaScriptEventLoop", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
                            .product(name: "DOM", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
                            .product(name: "FileSystem", package: "WebAPIKit", condition: .when(platforms: [.wasi])),
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
                        .define("GL_SILENCE_DEPRECATION", .when(platforms: [.macOS])),
                        .define("GLES_SILENCE_DEPRECATION", .when(platforms: [.iOS, .tvOS])),
                    ],
                    swiftSettings: {
                        var settings: [SwiftSetting] = []
                        
                        settings.append(contentsOf: [
                            // MARK: Gate Engine options.
                            /// Closes all open windows when the main window is closed
                            .define("GATEENGINE_CLOSES_ALLWINDOWS_WITH_MAINWINDOW", .when(platforms: .desktop)),
                            /// Checks for reloadable resources and reloads them if they have changed
                            .define("GATEENGINE_ENABLE_HOTRELOADING", .when(platforms: .desktop, configuration: .debug)),
                            /// The host platform requests the main window, so GateEngine won't create one until it's requested
                            .define("GATEENGINE_PLATFORM_CREATES_MAINWINDOW", .when(platforms: [.iOS, .tvOS])),
                            /// The host platform can't be used to compile HTML5 products
                            .define("GATEENGINE_WASI_UNSUPPORTED_HOST", .when(platforms: .any(except: .macOS, .linux))),
                            /// The host platform updates and draws from an event callback, so GateEngine won't create a game loop.
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN", .when(platforms: [.wasi])),
                            /// The host platform requires an intermediate task, so GateEngine won't load default systems.
                            .define("GATEENGINE_PLATFORM_DEFERS_LAUNCH", .when(platforms: [.wasi])),
                            /// The host platform supports file system read/write
                            .define("GATEENGINE_PLATFORM_HAS_FILESYSTEM", .when(platforms: .any)),
                            /// The host platform supports Foundation.FileManager
                            .define("GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER", .when(platforms: .any(except: .wasi))),
                        ])

                        // Use upcoming Swift Language Features
                        // https://www.swift.org/swift-evolution/#?upcoming=true
                        #if compiler(>=5.8)
                        settings.append(contentsOf: [
                            .unsafeFlags(["-enable-upcoming-feature", "DisableOutwardActorInference"]),
                            .unsafeFlags(["-enable-upcoming-feature", "ImportObjcForwardDeclarations"]),
                            .unsafeFlags(["-enable-upcoming-feature", "BareSlashRegexLiterals"]),
                            .unsafeFlags(["-enable-upcoming-feature", "ExistentialAny"]),
                            .unsafeFlags(["-enable-upcoming-feature", "ForwardTrailingClosures"]),
                            .unsafeFlags(["-enable-upcoming-feature", "ConciseMagicFile"]),
                        ])
                        #endif
                        
                        #if false // Options for development of GateEngine. These should be disabled for tagged version releases.
                        #warning("GateEngine development options are enabled. These can cause strange build errors on some platforms.")
                        
                        // Options for development of WASI platform
                        #if false
                        settings.append(contentsOf: [
                            /// Allows HTML5 platform to be compiled from a compatible host, such as macOS. This allows the IDE to show compile errors without targeting WASI.
                            .define("GATEENGINE_ENABLE_WASI_IDE_SUPPORT", .when(platforms: [.macOS, .linux], configuration: .debug)),
                            /// see comment in "Gate Engine options".
                            .define("GATEENGINE_PLATFORM_EVENT_DRIVEN", .when(platforms: [.macOS, .linux, .wasi], configuration: .debug)),
                        ])
                        #endif
                        
                        settings.append(contentsOf: [
                            /// Prints the output of generated shaders
                            .define("GATEENGINE_LOG_SHADERS"),
                            /// Enables various additional checks and output for rendering
                            .define("GATEENGINE_DEBUG_RENDERING"),
                            /// Enables various additional checks and output for input
                            .define("GATEENGINE_DEBUG_HID"),
                            /// Enables varius additional, additional, checks and output for input
                            .define("GATEENGINE_DEBUG_HID_VERBOSE"),
                            /// Forces Apple platforms to use OpenGL for rendering
                            .define("GATEENGINE_FORCE_OPNEGL_APPLE", .when(platforms: [.macOS, /*.iOS, .tvOS*/])),
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
                // Possibly faster on old hardware, but less accurate.
                // There is no reason to use this on modern hardware.
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
        
        // MARK: - Dependencies
        
        targets.append(contentsOf: [
            // Vorbis
            .target(name: "Vorbis",
                    path: "Dependencies/Vorbis",
                    publicHeadersPath: "include",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows]))
                    ]),
            
            // miniz
            .target(name: "MiniZ",
                    path: "Dependencies/MiniZ",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ]),
            
            // libspng
            .target(name: "LibSPNG",
                    dependencies: ["MiniZ"],
                    path: "Dependencies/LibSPNG",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("SPNG_STATIC"),
                        .define("SPNG_USE_MINIZ"),
                        // When public, the miniz.h header crashes Clang on Windows since Swift 5.8.0
                        .headerSearchPath("src/"),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ]),
            
            // TrueType
            .target(name: "TrueType",
                    path: "Dependencies/TrueType",
                    cSettings: [
                        .unsafeFlags(["-Wno-everything"]),
                        .define("STB_TRUETYPE_IMPLEMENTATION"), .define("STB_RECT_PACK_IMPLEMENTATION"),
                        .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                    ]),
            
            // Gravity
            .target(name: "Gravity",
                    path: "Dependencies/Gravity",
                    cSettings: [
                        .define("BUILD_GRAVITY_API"),
                        // WASI doesn't have umask
                        .define("umask(x)", to: "022", .when(platforms: [.wasi])),
                        // Windows doesn't support PIC flag
                        .unsafeFlags(["-fPIC"], .when(platforms: .any(except: .windows))),
                        .unsafeFlags(["-Wno-everything"]),
                        .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
                    ], linkerSettings: [
                        // For math functions
                        .linkedLibrary("m", .when(platforms: .any(except: .windows))),
                        // For path functions
                        .linkedLibrary("Shlwapi", .when(platforms: [.windows])),
                    ]),
        ])
        
        #if os(Windows)
        targets.append(
            // Direct3D12
            .target(name: "Direct3D12",
                    path: "Dependencies/Direct3D12",
                    swiftSettings: [
                        .define("Direct3D12ExcludeOriginalStyleAPI", .when(configuration: .release)),
                    ])
        )
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
                    dependencies: [.targetItem(name: "LinuxImports", condition: .when(platforms: [.linux])),
                                   .targetItem(name: "LinuxExtensions", condition: .when(platforms: [.linux]))],
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
        
        #if os(Linux) || os(Android) || os(Windows)
        targets.append(contentsOf: [
        // OpenALSoft
        .target(name: "OpenALSoft",
                path: "Dependencies/OpenAL/OpenALSoft",
                sources: openALSources,
                publicHeadersPath: "UnmodifiedSource/include",
                cxxSettings: openALCXXSettings,
                swiftSettings: {
                    var array: [SwiftSetting] = []
                    #if swift(>=5.9)
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
            .testTarget(name: "GateEngineTests",
                        dependencies: ["GateEngine"],
                        resources: [.copy("Resources")],
                        swiftSettings: [
                            .define("DISABLE_GRAVITY_TESTS", .when(platforms: [.wasi])),
                        ]),
            .testTarget(name: "GameMathTests",
                        dependencies: ["GameMath"]),
            .testTarget(name: "GravityTests",
                        dependencies: ["Gravity", "GateEngine"],
                        resources: [
                            .copy("Resources/disabled"),
                            .copy("Resources/fuzzy"),
                            .copy("Resources/infiniteloop"),
                            .copy("Resources/unittest"),
                        ],
                        swiftSettings: [
                            .define("DISABLE_GRAVITY_TESTS", .when(platforms: [.wasi])),
                        ]),
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


// Package.swift Helpers
extension Array where Element == Platform {
    static func any(except excluding: Platform...) -> Self {
        var array = self.any
        for platform in excluding {
            array.removeAll(where: {$0 == platform})
        }
        return array
    }
    
    static var desktop: Self {[.windows, .linux, .macOS]}
    static var mobile: Self {[.iOS, .tvOS, .android]}
    static var anyApple: Self {[.iOS, .tvOS, .macOS]}
    
    static var any: Self {[
        .macOS, .iOS, .tvOS,
        .linux, .android,
        .windows,
        .wasi,
    ]}
}

