// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var targets: [Target] {
    var array: [Target] = []
    
    array.append(.target(name: "Shaders", dependencies: ["GameMath"]))
    
    // TrueType
    array.append(
        .target(name: "TrueType",
                cSettings: [
                    .define("STB_TRUETYPE_IMPLEMENTATION"), .define("STB_RECT_PACK_IMPLEMENTATION"),
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                    .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                ],
                linkerSettings: [
                    // SR-14728
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ])
    )
    
    // libspng
    array.append(
        .target(name: "libspng",
                cSettings: [
                    .define("SPNG_USE_MINIZ"),
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows])),
                    .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])), // Silence warnings
                ],
                linkerSettings: [
                    // SR-14728
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ])
    )
    
    // Vorbis
    array.append(
        .target(name: "Vorbis",
                publicHeadersPath: "include",
                cSettings: [
                    .define("extern", to: "__declspec(dllexport) extern", .when(platforms: [.windows]))
                ],
                linkerSettings: [
                    // SR-14728
                    .linkedLibrary("swiftCore", .when(platforms: [.windows])),
                ])
    )
    
    // LinuxSupport
    array.append(contentsOf: [
        .target(name: "LinuxSupport", dependencies: ["LinuxImports", "LinuxExtensions"]),
        .target(name: "LinuxExtensions"),
        .systemLibrary(name: "LinuxImports"),
    ])
    
    return array
}

var products: [Product] {
    var array: [Product] = []
    
    array.append(.library(name: "Shaders", targets: ["Shaders"]))
    array.append(.library(name: "libspng", targets: ["libspng"]))
    array.append(.library(name: "TrueType", targets: ["TrueType"]))
    array.append(.library(name: "Vorbis", targets: ["Vorbis"]))
    array.append(.library(name: "LinuxSupport", targets: ["LinuxSupport"]))
    
    return array
}

let package = Package(
    name: "GateEngineDependencies",
    products: products,
    dependencies: [
        .package(url: "https://github.com/STREGAsGate/GameMath.git", .branch("master")),
    ],
    targets: targets,
    swiftLanguageVersions: [.v5]
)
